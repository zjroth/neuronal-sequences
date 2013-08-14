function N = computeN(vSeq, nMax)
    if isempty(vSeq)
        N = zeros(nMax, 1);
    else
        N = accumarray(vSeq, 1, [nMax, 1]);
    end
end