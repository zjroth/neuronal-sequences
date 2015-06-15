% vDistribution = computeRhoDistribution(vSeq1, vSeq2, nTrials)
function vDistribution = computeRhoDistribution(vSeq1, vSeq2, nTrials)
    % Initialize the return variable.
    vDistribution = zeros(1, nTrials);

    % Find a vector describing which neurons are active in both sequences.
    nMax = max([vSeq1; vSeq2]);
    vCoactive = (ind2log(vSeq1, nMax) & ind2log(vSeq2, nMax));

    % The count of neurons in a sequence doesn't change when the sequence is
    % shuffled.
    vN1 = computeN(vSeq1, nMax);
    vN2 = computeN(vSeq2, nMax);

    % For each trial, compute rho between shuffles of each sequence.
    for i = 1 : nTrials
        mtxMu1 = computeMu(biascount(shuffle(vSeq1), nMax), vN1);
        mtxMu2 = computeMu(biascount(shuffle(vSeq2), nMax), vN2);

        vDistribution(i) = computeRho(mtxMu1, mtxMu2, vCoactive);
    end
end