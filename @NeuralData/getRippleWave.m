%
% USAGE:
%
%     [rippleWave, rippleWaveTimes] = getRippleWave(this, varargin)
%
% DESCRIPTION:
%
%    Compute a ripple-wave signal.
%
% ARGUMENTS:
%
%    .
%       .
%
% RETURNS:
%
%    rippleWaveTs
%       A timeseries object whose data is the resultant ripple-wave signal
%
% NOTE:
%
%    See `help getRippleSpect` for optional parameters.
%
function [rippleWave, rippleWaveTimes] = getRippleWave(this, varargin)
    % Retrieve the spectrogram that's used to compute the ripple wave.
    [spect, rippleWaveTimes, ~] = getRippleSpectrogram(this, varargin{:});
    rippleWaveTimes = rippleWaveTimes(:);

    % Use the spectrogram to compute the ripple-wave signal.
    rippleWave = mean(spect, 1);
    rippleWave = rippleWave(:);

    % Smooth the signal.
    filter = gaussfilt(2 * round(this.smoothingRadius * sampleRate(this)) + 1);
    rippleWave = zscore(conv(rippleWave, filter, 'same'));
end
