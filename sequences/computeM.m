function M = computeM(vSeq, nMax)
    % Find the unique elements of the sequence.  This is much faster than
    % calling `unique(vSeq)`.
    vUnique = zeros(1, nMax);
    vUnique(vSeq) = 1;
    vUnique = find(vUnique);
    nElts = length(vUnique);

    % Build a matrix whose row `i` is the indicator vector of where `i` fires in
    % the sequence. This is an `nElts` by `length(vSeq2)` matrix.
    mtxSupports = bsxfun(@eq, vUnique(:), vSeq(:)');

    % Compute the small submatrix of M where non-zeros can exist. Things are
    % over-counted on the diagonal; fix this.
    mtxNumPrev = circshift(cumsum(mtxSupports, 2), [0, 1]);
    mtxNumPrev(:, 1) = 0;
    mtxM = mtxNumPrev * mtxSupports';

    % Fill in a full-size matrix M with the appropriate non-zero values.
    M = sparse([], [], [], nMax, nMax, nnz(mtxM));
    M(vUnique, vUnique) = mtxM;
end