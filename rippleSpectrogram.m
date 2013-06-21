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
function [spect, times, frequencies] = rippleSpectrogram(lfp, varargin)
    %=======================================================================
    % Default optional parameter values
    %=======================================================================

    % All times are in seconds, and all frequencies are in Hertz.
    sampleRate = 2e4;
    frequencyRange = [90, 180];
    windowWidth = 0.25;
    windowStep = (1 / sampleRate);

    % Replace the default values with any values that were passed to
    % the function.
    parseNamedParams();

    %=======================================================================
    % Actual computations
    %=======================================================================

    % Compute the actual short-time Fourier transforms for the desired
    % frequencies.
    [spect, times, frequencies] = MTSpectrogram( ...
        lfp         ,                            ...
        'frequency' , sampleRate,                ...
        'window'    , windowWidth,               ...
        'step'      , windowStep,                ...
        'range'     , frequencyRange             ...
    );

    % We want to account for the fact that "the power spectrum of intracortical
    % local field potential (LFP) often scales as 1/f^2". Note that this fact
    % seems not to hold for frequencies below about 10 Hz, which means that
    % we should probably be using a different method for the theta spectrogram.
    for i = 1 : length(frequencies)
        spect(i, :) = log(spect(i, :)) * log(frequencies(i));
    end
end