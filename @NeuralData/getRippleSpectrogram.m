%------------------------------------------------------------------------------
% USAGE:
%
%    rplPower = getRippleSpectrogram(this, ...)
%
% DESCRIPTION:
%
%    Compute a spectrogram for the given LFP.
%
% ARGUMENTS:
%
%    lfp
%       The LFP for which we are computing a spectrogram
%
% OPTIONAL PARAMETERS:
%
%    lfpSampleRate (default: 2e4)
%       The sample rate (in Hertz) of the provided LFP
%
%    frequencyRange (default: [90, 180])
%       The frequency range (in Hertz) for which the spectrogram will be
%       computed
%
%    sampleRate (default: 1250)
%       The rate (in Hertz) at which the resultant spectrogram will be sampled
%
%    windowWidth (default: 0.25)
%       The width (in seconds) of the window to use in the spectrogram
%       computation.
%
% RETURNS:
%
%    spect
%       The scaled spectrogram
%
%    spectTimes
%       The times (in seconds) for which the spectrogram contains data
%
%    spectFrequencies
%       The frequencies (in Hertz) for which the spectrogram contains data
%------------------------------------------------------------------------------
function [spect, spectTimes, spectFrequencies] = getRippleSpectrogram(this, varargin)
    %=======================================================================
    % Default optional parameter values
    %=======================================================================

    % All times are in seconds, and all frequencies are in Hertz.
    frequencyRange = [90, 180];
    windowWidth = 0.1;
    sampleRate = 1250;

    % Replace the default values with any values that were passed to
    % the function.
    parseNamedParams();

    %=======================================================================
    % Actual computations
    %=======================================================================

    % If this has been called before with the same parameters, then the data
    % should already be saved somewhere. Construct the filename here.
    [lfp, channel] = mainLfp(this);
    spectFolder = fullfile(this.baseFolder, 'computed', 'spects');
    spectFile = [                                                                ...
        'ch' num2str(channel) '-'                                                ...
        'range-' num2str(frequencyRange(1)) '-' num2str(frequencyRange(2)) 'Hz-' ...
        'window-' num2str(1000 * windowWidth) 'ms-'                              ...
        'rate-' num2str(sampleRate) 'Hz'                                         ...
        '.mat'];
    filename = fullfile(spectFolder, spectFile);

    % If the file already exists, simply load the data to be returned.
    if exist(filename, 'file')
        load(filename, 'spect', 'spectTimes', 'spectFrequencies');
    else
        % ...otherwise, compute the short-time Fourier transforms for the
        % desired frequencies.
        windowStep = (1 / sampleRate);

        [spect, spectTimes, spectFrequencies] = MTSpectrogram( ...
            lfp         ,                                      ...
            'frequency' , rawSampleRate(this),                 ...
            'window'    , windowWidth,                         ...
            'step'      , windowStep,                          ...
            'range'     , frequencyRange                       ...
        );

        % We want to account for the fact that "the power spectrum of intracortical
        % local field potential (LFP) often scales as 1/f^2" (for frequencies above
        % about 10 Hertz).
        for i = 1 : length(spectFrequencies)
            spect(i, :) = log(spect(i, :)) * log(spectFrequencies(i));
        end

        % Save this data so that we don't have to recompute this spectrogram in
        % the future.
        save(filename, 'frequencyRange', 'channel', 'spect', 'spectTimes', ...
            'spectFrequencies', 'windowWidth', 'sampleRate', '-v7.3');
    end

    this.current.spectrogram = spect;
    this.current.spectrogramTimes = spectTimes;
    this.current.spectrogramFrequencies = spectFrequencies;
end
