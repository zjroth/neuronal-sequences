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
function sharpWave = computeSharpWave(lowLfp, highLfp)
    % Create the "sharp-wave" ripple by subtracting the low LFP from the high LFP.
    shp = (highLfp - mean(highLfp)) - (lowLfp - mean(lowLfp));
end
