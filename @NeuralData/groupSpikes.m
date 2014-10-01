% function cellSpikeTimes = groupSpikes(this)
function cellSpikeTimes = groupSpikes(this)
    vRes = getSpike(this, 'res');
    vTotclu = getSpike(this, 'totclu');
    dRate = sampleRate(this);

    % Build a matrix of unique cell/shank combinations.
    nClusters = max(vTotclu);
    cellSpikeTimes = cell(nClusters, 1);

    % Group all of the clusters that are labeled the same. Also, convert from
    % index data to time data.
    for i = 1 : nClusters
        cellSpikeTimes{i} = vRes(vTotclu == i) / dRate;
    end

    this.data.spikeTrains = cellSpikeTimes;
end