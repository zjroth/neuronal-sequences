
% Load the LFP that we are going to be working with.
load('data/raw-lfp-data.mat');

% Compute the spectrogram every 2 milliseconds.
windowStep = 0.002;
sampleRate = 2e4;
frequencyRange = [90, 180];

% Run these computations for varying widths of the spectrogram
for windowWidthMS = (50 : 50 : 250)
    % Time these computations.
    startTic = tic();
    start = clock();
    startTime = [num2str(start(4)) ':' num2str(start(5)) ':' num2str(start(6))];
    windowWidth = windowWidthMS / 1000;

    disp(['Beginning computation of spectrogram with ' num2str(windowWidthMS) ...
          'ms window at time ' startTime ' (h:m:s)...']);

    % Compute the spectrogram.
    [spect, times, frequencies] = rippleSpectrogram( ...
        lfpMain,                                     ...
        'windowWidth', windowWidth,                  ...
        'windowStep', windowStep,                    ...
        'sampleRate', sampleRate,                    ...
        'frequencyRange', frequencyRange);

    % Display how long this computation took.
    endToc = toc(startTic);
    disp(['...computation took ' num2str(endToc) ' seconds to complete.']);

    % Save the computed data.
    filename = ['data/spect-' num2str(windowWidthMS) 'ms-window.mat'];
    save(filename, 'lfpMain', 'spect', 'times', 'frequencies', 'windowWidth', ...
        'windowStep', 'sampleRate', 'frequencyRange');

    % Avoid running out of memory by clearing the stored data.
    clear('spect', 'times', 'frequencies', 'startTic', 'endToc');
end

return;
%%

% Compute the spectrogram every 2 milliseconds.
windowStep = 0.002;
sampleRate = 2e4;
frequencyRange = [6, 10];

windowWidthMS = 500;

    % Time these computations.
    startTic = tic();
    start = clock();
    startTime = [num2str(start(4)) ':' num2str(start(5)) ':' num2str(start(6))];
    windowWidth = windowWidthMS / 1000;

    disp(['Beginning computation of spectrogram with ' num2str(windowWidthMS) ...
          'ms window at time ' startTime ' (h:m:s)...']);

    % Compute the spectrogram.
    [spect, times, frequencies] = MTSpectrogram( ...
        lfpMain,                                     ...
        'window', windowWidth,                  ...
        'step', windowStep,                    ...
        'frequency', sampleRate,                    ...
        'range', frequencyRange);

    % Display how long this computation took.
    endToc = toc(startTic);
    disp(['...computation took ' num2str(endToc) ' seconds to complete.']);

    % Save the computed data.
    filename = ['data/theta-spect-' num2str(windowWidthMS) 'ms-window.mat'];
    save(filename, 'lfpMain', 'spect', 'times', 'frequencies', 'windowWidth', ...
        'windowStep', 'sampleRate', 'frequencyRange');

