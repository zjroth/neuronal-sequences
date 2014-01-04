% USAGE:
%    [dPurity, dMagnitude, vMagnitudes] = purity(vSequence, nTrials)
%
% DESCRIPTION:
%    Compute (an apparoximation of) the purity of a sequence via monte-carlo
%    simulation.
%
% ARGUMENTS:
%    vSequence
%       The sequence for which to compute the purity
%    nTrials
%       The number of shufflings of this sequence to compute in determining
%       the sequence's purity
%
% RETURNS:
%    dPurity
%       The (estimation of the) vector's purity
%    dMagnitude
%       The maginitude of the vector corresponding to this sequence
%    vMagnitudes
%       The distribution of magnitudes used to compute the purity (p-value)
%
% ADDITIONAL INFOMRATION:
%    The purity of a sequence is related to the (vector) magnitude of the
%    corresponding pairwise-bias matrix. More specifically, the purity of a
%    sequence s is the p-value of ||mu(s)|| in the collection {||mu(v)|| : v is
%    a shuffling of s}. To ensure that sequences with one spike per neuron are
%    regarded as significant, we compute the p-value as the proportion of the
%    set with strictly larger magnitudes.
function [dPurity, dMagnitude, vMagnitudes] = purity(vSequence, nTrials)
    if isempty(vSequence)
        dPurity = 0;
        return;
    end

    vMagnitudes = zeros(nTrials, 1);
    dMagnitude = magnitude(vSequence);

    for i = 1 : nTrials
        vMagnitudes(i) = magnitude(shuffle(vSequence));
    end

    dPurity = 1 - nnz(vMagnitudes > dMagnitude) / nTrials;
end

function dMag = magnitude(vSeq)
    mtxBias = triu(orderBias(vSeq), 1);
    dMag = sqrt(sum(sum(mtxBias.^2)));
end
