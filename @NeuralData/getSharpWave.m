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
        % Our sharp-wave signal will start off as the zscore signal of the
        % difference of the high and low LFPs.
        vSharpWave = zscore(highLfp(this) - lowLfp(this));

        % Downsample the signal to this object's sample rate.
        if sampleRate(this) ~= rawSampleRate(this)
            vSharpWave = vSharpWave( ...
                round(1 : rawSampleRate(this) / sampleRate(this) : end));
        end

        % Center each point of the sharp-wave signal at the local average around
        % that point. This should allow features on the timescale of a ripple to
        % be more prominant.
        nAveragingFilterLength = round(0.5 * sampleRate(this));
        vAveragingFilter = ones(1, nAveragingFilterLength) ./ nAveragingFilterLength;
        vLocalAverage = conv(vSharpWave, vAveragingFilter, 'same');
        vSharpWave = vSharpWave - vLocalAverage;

        % Smooth the signal.
        filter = gaussfilt(2 * round(this.smoothingRadius * sampleRate(this)) + 1);
        vSharpWave = zscore(conv(vSharpWave, filter, 'same'));

        % Retrieve the times and store the sharp-wave signal in this object.
        vTimes = (0 : length(vSharpWave) - 1) / sampleRate(this);
        this.current.sharpWave = TimeSeries(vSharpWave, vTimes);
    end

    % Retrieve the stored sharp-wave signal.
    objSharpWave = this.current.sharpWave;

    % Ensure, if the ripple-wave signal has been computed, that the sharp-wave
    % signal's sample times agree with the sample times of the ripple-wave.
    if isfield(this.current, 'rippleWave')
        objRippleWave = getRippleWave(this);

        if objRippleWave.Time(1) > objSharpWave.Time(1)
            vIndices = round(objRippleWave.Time * sampleRate(this));
            this.current.sharpWave = TimeSeries( ...
                objSharpWave.Data(vIndices), objRippleWave.Time);
        elseif objRippleWave.Time(1) < objSharpWave.Time(1)
            error(['getSharpWave: nobody should ever get this error; ' ...
                   'something went wrong...']);
        end
    end
end
