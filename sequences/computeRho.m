function dRho = computeRho(mtxMu1, mtxMu2)
    dNumerator = full(sum(sum(mtxMu1 .* mtxMu2)));
    dDenominator = full(sqrt(sum(sum(mtxMu1 .* mtxMu1)) * sum(sum(mtxMu2 .* mtxMu2))));
    dRho = dNumerator / dDenominator;
end