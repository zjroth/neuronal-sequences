% function clusterSpikeTimes = groupSpikes(this)
function cellSpikeTimes = groupSpikes(this)
    % Build a matrix of unique cell/shank combinations.
    numClusters = max(this.Spike.totclu);
    cellSpikeTimes = cell(numClusters, 1);

    % Group all of the clusters that are labeled the same. Also, convert from
    % index data to time data.
    for i = 1 : numClusters
        cellSpikeTimes{i} = this.Spike.res(this.Spike.totclu == i) / sampleRate(this);
    end

    this.current.spikeTrains = cellSpikeTimes;
end