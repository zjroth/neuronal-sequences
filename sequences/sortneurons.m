% vOrdering = sortneurons(cellSpikeTrains, varargin)
function vOrdering = sortneurons(vSeq, bRestrictToActive)
    if nargin < 2
        bRestrictToActive = true;
    end

    cellSpikeTrains = spikesets(vSeq);
    nNeurons = length(cellSpikeTrains);
    vCentersOfMass = zeros(nNeurons, 1);

    for j = 1 : nNeurons
        vTrain = cellSpikeTrains{j};
        vCentersOfMass(j) = mean(vTrain);
    end

    [~, vOrdering] = sort(vCentersOfMass);

    if bRestrictToActive
        vOrdering = vOrdering(1 : nnz(~isnan(vCentersOfMass)));
    end
end