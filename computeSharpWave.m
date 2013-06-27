%------------------------------------------------------------------------------
% USAGE:
%
%    sharpWave = computeSharpWave(lowLfp, highLfp)
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
function sharpWave = computeSharpWave(lowLfp, highLfp)
    % Center the two LFPs at zero (i.e., subtract their means), take their
    % difference, and then normalize the resultant signal.
    sharpWave = zscore((highLfp - mean(highLfp)) - (lowLfp - mean(lowLfp)));
end
