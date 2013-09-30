% vOrdering = sortNeurons(cellSpikeTrains, varargin)
function vOrdering = sortNeurons(cellSpikeTrains, bRestrictToActive)
    if nargin < 2
        bRestrictToActive = true;
    end

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