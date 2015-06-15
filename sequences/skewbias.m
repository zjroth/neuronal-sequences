% USAGE:
%    mtxBias = skewbias(vSeq)
%
% DESCRIPTION:
%    Compute the order-bias matrix (i.e., the "mu" matrix) for the given
%    sequence. This is a convenience function for when the lower-level
%    functionality of `computeMu` isn't needed.
%
% ARGUMENTS:
%    vSeq
%       The sequence for which to compute the order-bias matrix
function mtxBias = skewbias(vSeq, nMaxElt)
    if nargin < 2
        nMaxElt = max(vSeq);
    end

    mtxBias = computeMu(biascount(vSeq, nMaxElt), computeN(vSeq, nMaxElt));
end
