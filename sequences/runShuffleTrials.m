% arrRhoMatrices = runShuffleTrials(cellSeqs, nTrials, strFolder)
function arrRhoMatrices = runShuffleTrials(cellSeqs, nTrials, strFolder)
    % Some initialization.
    nSeqs = length(cellSeqs);
    arrRhoMatrices = zeros(nSeqs, nSeqs, nTrials);

    % Determine whether or not we should be saving the individual rho matrices
    % to files in a specified folder.
    bSaveFiles = exist('strFolder', 'var');

    % For each trial...
    parfor i = 1 : nTrials
        % ...compute the rho matrix for a collection of shuffled sequences.
        cellShuffled = cellfun(@shuffle, cellSeqs, 'UniformOutput', false);
        mtxRho = computeRhoMatrix(cellShuffled, 0);

        % Save the files if requested.
        if bSaveFiles
            saveRho([strFolder 'trial-' num2str(i)], mtxRho)
        end

        % Add this matrix to the return variable.
        arrRhoMatrices(:, :, i) = mtxRho;
    end
end

% A function for saving within a `parfor` loop. Replacing the invocation of this
% function with the one line that it contains will cause a transparency
% violation error.
function saveRho(strFile, mtxRho)
    save(strFile, '-v7.3', 'mtxRho');
end