% A small script for loading and plotting channel data from a file.

% This is the name of the file minus its extension (i.e., ".dat").
filename_prefix = ['/home/s-zroth1/data/Eva-new-maze-2013/' ...
                   'A543-20120422-01/A543-20120422-01'];

% This information was taken from `[filename_prefix '.meta']`.
nChannelsTot = 256;
sampleRate   = 20000;

% A function for converting a time in minutes, seconds, and
% milliseconds into milliseconds.
time2ms = @(m, s, ms) 60000 * m + 1000 * s + ms;

% These three channels have a ripple in this time window (as indicated
% by an email from Eva via Vladimir on March 12, 2013).
chIDs           = [33, 34, 45];
startReadInMS   = time2ms(5, 37, 200);
chunkLengthInMS = 30;

% The times given in milliseconds must be converted to sample
% numbers (e.g., at 20 kHz, 1 ms is sample number 20000).
startRead   = startReadInMS * (sampleRate / 1000);
chunkLength = chunkLengthInMS * (sampleRate / 1000);

% Initialize some variables for loading the data.
currChannelIdx = 0;
eeg = zeros(chunkLength, length(chIDs));

% Load the data for each channel. This opens and closes the file for
% each channel and is not meant to be efficient. The function
% `LoadDatFile` should be tweaked to load data for several channels.
for id = chIDs
  currChannelIdx = currChannelIdx + 1;
  eeg(:, currChannelIdx) = LoadDatFile(filename_prefix, id, startRead, ...
                                       chunkLength, nChannelsTot);
end

% Plot the results as a sanity check.
plot(eeg);
legend(cellstr(num2str(chIDs', 'Channel %i')))