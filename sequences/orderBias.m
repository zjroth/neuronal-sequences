% USAGE:
%    mtxBias = orderBias(vSeq)
%
% DESCRIPTION:
%    Compute the order-bias matrix (i.e., the "mu" matrix) for the given
%    sequence. This is a convenience function for when the lower-level
%    functionality of `computeMu` isn't needed.
%
% ARGUMENTS:
%
%    vSeq
%       The sequence for which to compute the order-bias matrix
function mtxBias = orderBias(vSeq)
    nMaxElt = max(vSeq);
    mtxBias = computeMu(countOrderedPairs(vSeq, nMaxElt), computeN(vSeq, nMaxElt));
end
