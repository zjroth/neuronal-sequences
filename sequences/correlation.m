function dCorr = correlation(vSeq1, vSeq2)
    vCommon = intersect(vSeq1, vSeq2);

    if length(vCommon) < 2
        dCorr = 0;
    else
        nNeurons = max(max(vSeq1), max(vSeq2));
        mtxBias1 = skewbias(vSeq1, nNeurons);
        mtxBias2 = skewbias(vSeq2, nNeurons);
        dCorr = computeRho(mtxBias1, mtxBias2, vCommon);
    end
end
