% mtxSeqs = toMatrix(cellSeqs)
function mtxSeqs = toMatrix(cellSeqs, nMaxElt)
    % Store the number of sequences, and compute the maximum neuron
    % value that is involved in any of the provided sequences.
    nSeqs = length(cellSeqs);

    if nargin < 2
        nMaxElt = maxActive(cellSeqs);
    end

    % Initialize the return value. Each sequence corresponds to a row
    % of this matrix.
    % NOTE: It might make sense to make this into a sparse matrix.
    mtxSeqs = zeros(nSeqs, nMaxElt);

    % Since neurons are represented as natural numbers, we can find
    % the activity of a given sequence by simply assigning `1` to the
    % index that is the neuron value.
    for i = 1 : nSeqs
        mtxSeqs(i, cellSeqs{i}) = 1;
    end

    % This is only possible if `nMaxElt` was passed in.
    if size(mtxSeqs, 2) > nMaxElt
        mtxSeqs(:, nMaxElt + 1 : end) = [];
    end
end
