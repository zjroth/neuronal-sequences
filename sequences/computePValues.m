% mtxP = computePValues(cellSeqs, nTrials, strFolder)
function mtxP = computePValues(cellSeqs, nTrials, strFolder)
    % Determine whether or not we should be saving the individual rho matrices
    % to files in a specified folder.
    bSaveFiles = exist('strFolder', 'var') && ~isempty(strFolder);

    % Find which neurons are active in each sequence, and compute the number
    % of neurons that are active in each pair of sequnces.
    mtxActivity = toMatrix(cellSeqs);
    mtxNumCoactive = mtxActivity * mtxActivity.';

    % Store the number of sequences.
    nSequences = length(cellSeqs);

    % To compute p, we need rho for each pair of sequences. Initialize the
    % return variable under the assumption that all rho values are
    % insignificant.
    mtxRho = computeRhoMatrix(cellSeqs, 0);
    mtxP = ones(nSequences);

    % For each pair of sequences...
    for i = 1 : nSequences - 1
        parfor j = i + 1 : nSequences
            if mtxNumCoactive(i, j) > 3
                % ...compute a distribution of rho values for the current
                % pair of sequences.
                vDistribution = computeRhoDistribution(cellSeqs{i}, ...
                                                       cellSeqs{j}, nTrials);

                % Save the distribution if a folder was provided.
                if bSaveFiles
                    saveDistribution([strFolder 'seqs-' num2str(i) '-' num2str(j)], ...
                            vDistribution);
                end

                % Compute p.
                mtxP(i, j) = nnz(abs(vDistribution) > abs(mtxRho(i, j))) / ...
                    nTrials;
            end
        end
    end

    % Make the matrix of p values symmetric. This couldn't be done inside of
    % a parfor-loop.
    mtxP = triu(mtxP) + triu(mtxP, 1).';
end

% A function for saving within a `parfor` loop. Replacing the invocation of this
% function with the one line that it contains will cause a transparency
% violation error.
function saveDistribution(strFile, vDistribution)
    save(strFile, '-v7.3', 'vDistribution');
end