%------------------------------------------------------------------------------
% USAGE:
%
%    sharpWave = getSharpWave(this)
%
% DESCRIPTION:
%
%    Compute a scaled sharp-wave signal based on the two provided LFPs.
%
% ARGUMENTS:
%
%    lowLfp
%       .
%
%    highLfp
%       .
%
% RETURNS:
%
%    sharpWave
%       .
%
%------------------------------------------------------------------------------
function sharpWave = getSharpWave(this)
    if ~isfield(this.current, 'sharpWave')
        % Center the two LFPs at zero (i.e., subtract their means), take their
        % difference, and then normalize the resultant signal.
        sharpWave = ...
            (highLfp(this) - mean(highLfp(this))) - ...
            (lowLfp(this) - mean(lowLfp(this)));

        % Smooth the signal.
        filter = gaussfilt(2 * round(this.smoothingRadius * rawSampleRate(this)) + 1);
        this.current.sharpWave = zscore(conv(sharpWave, filter, 'same'));

        % Downsample the signal to agree with the ripple wave.
        [~, vRippleWaveTimes] = getRippleWave(this);
        vIndices = round(vRippleWaveTimes * rawSampleRate(this));
        this.current.sharpWave = this.current.sharpWave(timeDataIndices);
    end

    sharpWave = this.current.sharpWave;
end
