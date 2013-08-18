% mtxRhoNaught = computeRhoNaughtMatrix(cellSeqs, nTrials, dProb)
function [mtxRhoNaught, arrRhoMatrices] = computeRhoNaughtMatrix(cellSeqs, nTrials, dProb)
    % Some initialization.
    nSeqs = length(cellSeqs);
    arrRhoMatrices = zeros(nSeqs, nSeqs, nTrials);

    % For each trial...
    parfor i = 1 : nTrials
        % ...compute the rho matrix for a collection of shuffled sequences.
        cellShuffled = cellfun(@shuffle, cellSeqs, 'UniformOutput', false);
        arrRhoMatrices(:, :, i) = computeRhoMatrix(cellShuffled, 0);
    end

    % Sort the rho values for each pair of sequences (individually), then pick
    % out the matrix of rho_naught values to return.
    arrRhoSorted = sort(abs(arrRhoMatrices), 3, 'descend');
    mtxRhoNaught = arrRhoSorted(:, :, floor(nTrials * dProb));
end
