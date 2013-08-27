function N = computeN(vSeq, nMax)
    if isempty(vSeq)
        N = sparse(nMax, 1);
    else
        N = sparse(accumarray(vSeq(:), 1, [nMax, 1]));
    end
end