function mtxM = computeM(vSeq, nMax)
    % Find the unique elements of the sequence.  This is much faster than
    % calling `unique(vSeq)`.
    vUnique = zeros(1, nMax);
    vUnique(vSeq) = 1;
    vUnique = find(vUnique);

    % We will proceed by mapping each element of `vSeq` to its index in
    % `vUnique`, thus allowing us to work with a sequence whose elements are
    % in the range from one to the length of `vUnique`. The second line below
    % does this mapping.
    nElts = length(vUnique);

    % Build a matrix whose row `i` is the indicator vector of where `i` fires in
    % the sequence. This is an `nElts` by `length(vSeq2)` matrix.
    mtxSupports = bsxfun(@eq, vUnique(:), vSeq(:)');

    % for i = 1 : nElts
    %     mtxSupports(i, :) = (vSeq == vUnique(i));
    % end

    % Compute the small submatrix of M where non-zeros can exist.
    mtxM = cumsum(mtxSupports, 2) * mtxSupports';

    % Fill in a full-size matrix M with the appropriate non-zero values.
    M = sparse([], [], [], nMax, nMax, nnz(mtxM));
    M(vUnique, vUnique) = mtxM;
end