% USAGE:
%     objRippleWave = getRippleWave(this, varargin)
%
% DESCRIPTION:
%    Compute a ripple-wave signal.
%
% RETURNS:
%    rippleWaveTs
%       A TimeSeries object whose data is the resultant ripple-wave signal
%
% NOTE:
%    See `help getRippleSpectrogram` for optional parameters.
function objRippleWave = getRippleWave(this, varargin)
    if ~isfield(this.current, 'rippleWave')
        % Retrieve the spectrogram that's used to compute the ripple wave.
        [spect, rippleWaveTimes, ~] = getRippleSpectrogram(this, varargin{:});
        rippleWaveTimes = rippleWaveTimes(:);

        % Use the spectrogram to compute the ripple-wave signal.
        rippleWave = mean(spect, 1);
        rippleWave = rippleWave(:);

        % Smooth the signal.
        filter = gaussfilt(2 * round(this.smoothingRadius * sampleRate(this)) + 1);
        rippleWave = zscore(conv(rippleWave, filter, 'same'));
        this.current.rippleWave = TimeSeries(rippleWave, rippleWaveTimes);
    end

    objRippleWave = this.current.rippleWave;
end
