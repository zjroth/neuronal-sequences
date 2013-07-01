%------------------------------------------------------------------------------
% USAGE:
%
%    rplPower = rippleSpectrogram(lfp, ...)
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
%    windowStep (default: 1 / lfpSampleRate)
%       The step (in seconds) between the centers of successive windows used in
%       the spectrogram computation
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
%    times
%       The times (in seconds) for which the spectrogram contains data
%
%    frequencies
%       The frequencies (in Hertz) for which the spectrogram contains data
%------------------------------------------------------------------------------
function [spect, spectTimes, spectFrequencies] = rippleSpectrogram(lfp, varargin)
    %=======================================================================
    % Default optional parameter values
    %=======================================================================

    % All times are in seconds, and all frequencies are in Hertz.
    lfpSampleRate = 2e4;
    frequencyRange = [90, 180];
    windowWidth = 0.25;

    % Replace the default values with any values that were passed to
    % the function.
    parseNamedParams();

    if ~exist('windowStep', 'var')
        windowStep = (1 / lfpSampleRate);
    end

    %=======================================================================
    % Actual computations
    %=======================================================================

    % Compute the actual short-time Fourier transforms for the desired
    % frequencies.
    [spect, spectTimes, spectFrequencies] = MTSpectrogram( ...
        lfp         ,                                      ...
        'frequency' , sampleRate,                          ...
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

    % Save the data if requested.
    if exist('outputFile', 'var')
        save(outputFile, 'frequencyRange', 'lfp', 'spect', 'spectTimes', ...
            'spectFrequencies', 'lfpSampleRate', 'windowWidth', ...
            'windowStep');
    end
end