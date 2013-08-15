function dRho = computeRho(mtxMu1, mtxMu2, vCommonNeurons)
    % Restrict to the submatrices that correspond to the neurons that the
    % corresponding sequences share.
    mtxLocalMu1 = mtxMu1(vCommonNeurons, vCommonNeurons);
    mtxLocalMu2 = mtxMu2(vCommonNeurons, vCommonNeurons);

    % Now that the above restriction has been performed, the computation of rho
    % is straightforward.
    dDotProduct = full(sum(sum(mtxLocalMu1 .* mtxLocalMu2)));
    dNorm1 = sqrt(sum(sum(mtxLocalMu1 .* mtxLocalMu1)));
    dNorm2 = sqrt(sum(sum(mtxLocalMu2 .* mtxLocalMu2)));

    dRho = dDotProduct / (dNorm1 * dNorm2);
end