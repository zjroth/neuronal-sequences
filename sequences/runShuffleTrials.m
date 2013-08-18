%  arrRhoMatrices = runShuffleTrials(cellSeqs, nTrials)
function arrRhoMatrices = runShuffleTrials(cellSeqs, nTrials)
    % Some initialization.
    nSeqs = length(cellSeqs);
    arrRhoMatrices = zeros(nSeqs, nSeqs, nTrials);

    % For each trial...
    parfor i = 1 : nTrials
        % ...compute the rho matrix for a collection of shuffled sequences.
        cellShuffled = cellfun(@shuffle, cellSeqs, 'UniformOutput', false);
        arrRhoMatrices(:, :, i) = computeRhoMatrix(cellShuffled, 0);
    end
end
