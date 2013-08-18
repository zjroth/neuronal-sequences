% mtxRhoNaught = computeRhoNaughtMatrix(cellSeqs, nTrials, dProb)
function mtxRhoNaught = computeRhoNaughtMatrix(arrRhoMatrices, dProb)
    % Sort the rho values for each pair of sequences (individually), then pick
    % out the matrix of rho_naught values to return.
    arrRhoMatricesSorted = sort(abs(arrRhoMatrices), 3, 'descend');
    mtxRhoNaught = arrRhoMatricesSorted(:, :, floor(nTrials * dProb));
end
