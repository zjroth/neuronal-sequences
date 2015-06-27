% USAGE:
%    mtxCounts = biascount(vSequence, nMax)
%
% DESCRIPTION:
%    Compute the number of times that the pair (i, j) occurs in order in the
%    given sequence.
%
% ARGUMENTS:
%    vSequence
%       The input sequence as a vector of positive indices
%    nMax
%       The total number of neurons in consideration; this will determine the
%       size of the output matrix
%
% RETURNS:
%    mtxCounts
%       A sparse matrix, the (i, j) entry of which will contain the number of
%       times that neuron j fires after neuron i; the diagonal of this matrix
%       will always be zero (by definition of the function, not of the above
%       procedure).
%
% EXAMPLE:
%    >> v = [1, 3, 2, 2, 4, 2, 1];
%    >> n = 5;
%    >> full(biascount(v, n))
%
%    ans =
%
%         0     3     1     1     0
%         3     0     0     2     0
%         1     3     0     1     0
%         1     1     0     0     0
%         0     0     0     0     0
function mtxCounts = biascount(vSequence, nMax)
    if nargin < 2
        nMax = max(vSequence);
    end

    % Find the unique elements of the sequence.  This is much faster than
    % calling `unique(vSequence)`.
    vNeurons = zeros(1, nMax);
    vNeurons(vSequence) = 1;
    vNeurons = find(vNeurons);

    % Build a matrix whose row `i` is the indicator vector of where `i` fires in
    % the sequence.
    mtxSupports = bsxfun(@eq, vNeurons(:), vSequence(:)');

    % Compute the small submatrix of M where non-zeros can exist.
    mtxCountsRestricted = cumsum(mtxSupports, 2) * mtxSupports';
    vDiagonalIndices = 1 : length(vNeurons) + 1 : numel(mtxCountsRestricted);
    mtxCountsRestricted(vDiagonalIndices) = 0;

    % Fill in a full-size matrix M with the appropriate non-zero values.
    mtxCounts = sparse([], [], [], nMax, nMax, nnz(mtxCountsRestricted));
    mtxCounts(vNeurons, vNeurons) = mtxCountsRestricted;
end
