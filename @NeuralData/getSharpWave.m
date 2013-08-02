%------------------------------------------------------------------------------
% USAGE:
%
%    objSharpWave = getSharpWave(this)
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
%    objSharpWave
%       .
%
%------------------------------------------------------------------------------
function objSharpWave = getSharpWave(this)
    if ~isfield(this.current, 'sharpWave')
        % Center the two LFPs at zero (i.e., subtract their means), take their
        % difference, and then normalize the resultant signal.
        vSharpWave = ...
            (highLfp(this) - mean(highLfp(this))) - ...
            (lowLfp(this) - mean(lowLfp(this)));

        % Smooth the signal.
        filter = gaussfilt(2 * round(this.smoothingRadius * rawSampleRate(this)) + 1);
        this.current.sharpWave = zscore(conv(vSharpWave, filter, 'same'));

        % Downsample the signal to agree with the ripple wave.
        objRippleWave = getRippleWave(this);
        vIndices = round(objRippleWave.Time * rawSampleRate(this));
        this.current.sharpWave = TimeSeries( ...
            vSharpWave(vIndices), objRippleWave.Time);
    end

    sharpWave = this.current.sharpWave;
end
