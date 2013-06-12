% Some initialization stuff...
filename = ['/home/s-zroth1/data/Eva-new-maze-2013/' ...
            'A543-20120422-01/A543-20120422-01.sev'];
channels   = [34, 35, 46];
sampleRate = 2e4;
nChannels  = 256;

% Load the data.
disp('Loading the data...');
listing = dir(filename);
Nsamples = listing.bytes / (2 * nChannels);  % sec

nch = 0;
for currChannel = channels
    fidSev = fopen(filename, 'r');
    startRead = (currChannel - 1) * Nsamples * 2;

    nch = nch + 1;
    dat(:, nch) = LoadSevFile(fidSev, startRead, Nsamples);
end

% Find the ripples
[spw, fShp, fRip] = ripdetect_sev(dat, sampleRate);