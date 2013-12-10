function [mtxP, mtxCounts] = computePValues(cellSeqs, nTrials)
    % Find which neurons are active in each sequence, and compute the number
    % of neurons that are active in each pair of sequences.
    mtxActivity = toMatrix(cellSeqs);
    mtxNumCoactive = mtxActivity * mtxActivity.';

    % Store the number of sequences.
    nSequences = length(cellSeqs);

    % To compute p, we need rho for each pair of sequences. Initialize the
    % return variable under the assumption that all rho values are
    % insignificant.
    mtxRho = abs(computeRhoMatrix(cellSeqs, 0));
    mtxCounts = zeros(nSequences);

    % For each trial...
    parfor i = 1 : nTrials
        % ...compute the rho matrix for a collection of shuffled sequences.
        cellShuffled = cellfun(@shuffle, cellSeqs, 'UniformOutput', false);
        mtxRhoShuffled = abs(computeRhoMatrix(cellShuffled, 0));

        % Add this matrix to the return variable.
        mtxCounts = mtxCounts + (mtxRhoShuffled > mtxRho);
    end

    % Build our return variable.
    mtxP = ones(nSequences);
    mtxP(mtxNumCoactive > 3) = mtxCounts(mtxNumCoactive > 3) ./ nTrials;
end
