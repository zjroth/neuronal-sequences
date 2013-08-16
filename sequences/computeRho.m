% dRho = computeRho(mtxMu1, mtxMu2, vCommonNeurons)
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
    dDenom = dNorm1 * dNorm2;

    % Account for the case that one of the restricted matrices is a zero-matrix.
    % This can happen even if the corresponding sequences have common neurons
    % since the mu-matrices are stored as upper-triangular matrices despite the
    % fact that the full matrix of mu values would not be symmetric.
    if dDenom ~= 0
        dRho = dDotProduct / dDenom;
    else
        dRho = 0;
    end
end