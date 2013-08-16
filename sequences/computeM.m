% mtxM = computeM(vSeq, nMax)
function mtxM = computeM(vSeq, nMax)
    % Find the unique elements of the sequence.  This is much faster than
    % calling `unique(vSeq)`.
    vUnique = zeros(1, nMax);
    vUnique(vSeq) = 1;
    vUnique = find(vUnique);

    % Build a matrix whose row `i` is the indicator vector of where `i` fires in
    % the sequence.
    mtxSupports = bsxfun(@eq, vUnique(:), vSeq(:)');

    % Compute the small submatrix of M where non-zeros can exist.
    mtxMRestricted = triu(cumsum(mtxSupports, 2) * mtxSupports', 1);

    % Fill in a full-size matrix M with the appropriate non-zero values.
    mtxM = sparse([], [], [], nMax, nMax, nnz(mtxMRestricted));
    mtxM(vUnique, vUnique) = mtxMRestricted;
end