% USAGE:
%    [mtxCoactive, mtxActivityX, mtxActivityY] = coactivity(cellSeqsX, <cellSeqsY>)
%
% DESCRIPTION:
%    Find the coactivity matrix of a pair of sequence lists.
%
% ARGUMENTS:
%    cellSeqsX, <cellSeqsY>
%       The lists (cell arrays) of sequences. If the second of these is
%       omitted, then it is set equal to the first.
%
% RETURNS:
%    mtxCoactive
%       The coactivity matrix. An the (i, j) entry of this matrix tells how many
%       neurons sequence j of `cellSeqsX` has in common with sequence i of
%       `cellSeqsY`.
%    mtxActivityX, mtxActivityY
%       The activity matrices (i.e., the return variables of `activitymatrix`) of the
%       input arguments since they have to be computed as an intermediate step
%       of this computation.
function [mtxCoactive, mtxActivityX, mtxActivityY] = coactivity(cellSeqsX, cellSeqsY)
    if nargin < 2
        cellSeqsY = cellSeqsX;
    end

    nNeurons = maxActive([cellSeqsX(:); cellSeqsY(:)]);
    mtxActivityX = activitymatrix(cellSeqsX, nNeurons);
    mtxActivityY = activitymatrix(cellSeqsY, nNeurons);
    mtxCoactive = mtxActivityY * mtxActivityX.';
end
