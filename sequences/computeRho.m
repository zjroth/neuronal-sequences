% dRho = computeRho(mtxMu1, mtxMu2, vCommonNeurons)
function dRho = computeRho(mtxMu1, mtxMu2, vCommonNeurons)
    % Restrict to the submatrices that correspond to the neurons that the
    % corresponding sequences share, and extract the upper-triangular portion
    % as a vector.
    vMu1 = triu(mtxMu1(vCommonNeurons, vCommonNeurons), 1);
    vMu2 = triu(mtxMu2(vCommonNeurons, vCommonNeurons), 1);

    % Now that the above restriction has been performed, the computation of rho
    % is straightforward.
    dDotProduct = full(sum(sum(vMu1 .* vMu2)));
    dDenom = sqrt(sum(sum(vMu1 .* vMu1)) * sum(sum(vMu2 .* vMu2)));

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