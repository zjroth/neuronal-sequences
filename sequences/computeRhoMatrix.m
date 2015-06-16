% [mtxRho, vIncluded] = computeRhoMatrix(cellSequences, vNumActiveNeurons)
function [mtxRho, vIncluded] = computeRhoMatrix(cellSequences, vNumActiveNeurons)
    % Set the default value for the allowed number of neurons in a sequence.  I
    % think we should probably just get rid of this parameters and do more
    % post-processing on the overlaps of sequences.
    if nargin < 2
        vNumActiveNeurons = [0, Inf];
    elseif isscalar(vNumActiveNeurons)
        vNumActiveNeurons = [vNumActiveNeurons, Inf];
    end

    % Retrieve the number of active neurons in each sequence, and restrict the
    % sequences to be processed to those with an appropriate number of active
    % neurons. Keep track of which sequences are to be included, and store the
    % total number of sequences that we'll be working with.
    vSeqSetSizes = sum(activitymatrix(cellSequences), 2);
    vIncluded = find(vNumActiveNeurons(1) <= vSeqSetSizes & vSeqSetSizes <= vNumActiveNeurons(2));
    nSequences = length(vIncluded);

    % Find the neuron activity for each sequence and the number of neurons that
    % are active in each pair of sequences.
    mtxNeuronActivity = activitymatrix(cellSequences(vIncluded));
    mtxNumCoactive = mtxNeuronActivity * mtxNeuronActivity';

    % Store the total number of neurons.
    nNeurons = size(mtxNeuronActivity, 2);

    % Precompute all M, N, and Mu values.
    cellM = cell(nSequences, 1);
    cellN = cell(nSequences, 1);
    cellMu = cell(nSequences, 1);

    for i = 1 : nSequences
        cellPairCounts{i} = skewbias(cellSequences{vIncluded(i)}, nNeurons);
        cellN{i} = spikecount(cellSequences{vIncluded(i)}, nNeurons);
        cellMu{i} = computeMu(cellPairCounts{i}, cellN{i});
    end

    % Initialize the matrix of rho values.
    mtxRho = eye(nSequences);

    % Since $\rho(s_1, s_2) = \rho(s_2, s_1)$, we need only to compute the
    % upper-triangular portion of `mtxRho`. Since $\rho(s, s) = 1$ unless $s$ is
    % empty, we also need not compute diagonal entries.
    for i = 1 : nSequences - 1
        for j = i + 1 : nSequences
            % A rho value should remain zero if two sequences share no common
            % active neurons.
            if mtxNumCoactive(i, j) > 1
                vCoactive = (mtxNeuronActivity(i, :) & mtxNeuronActivity(j, :));
                mtxRho(i, j) = computeRho(cellMu{i}, cellMu{j}, vCoactive);
                mtxRho(j, i) = mtxRho(i, j);
            end
        end
    end
end
