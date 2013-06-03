%------------------------------------------------------------------------------
% Usage:
%    sharpWave = computeSharpWave(lowLfp, highLfp)
% Description:
%    Compute a smoothed, scaled "sharp-wave" ripple based on the two provided
%    LFPs...I think.  Here is Eva's original comment describing this code:
%    "detect sharp waves based on SD-based threshold:".
% Arguments:
%    lowLfp
%       .
%    highLfp
%       .
%    smoothingFilter
%       .
% Returns:
%    sharpWave
%       .
%------------------------------------------------------------------------------
function sharpWave = computeSharpWave(lowLfp, highLfp, smoothingFilter)
    % Create the "sharp-wave" ripple by subtracting the low LFP from the high LFP.
    shp = (highLfp - mean(highLfp)) - (lowLfp - mean(lowLfp));

    % Smooth the sharp-wave.
    fShp = conv(shp, smoothingFilter, 'same');

    % Pass the smoothed sharp-wave through `unity`. I believe that `unity` is
    % supposed to take care of scaling issues, but I'm not sure. Eva's
    % original note for this line is simply "z-score", suggesting to me that
    % this is supposed to be an approximation for the z-score for each data
    % point; however, a value dependent on the median is used rather than the
    % standard deviation in the computation of this purported z-score.
    sharpWave = unity(fShp);
end