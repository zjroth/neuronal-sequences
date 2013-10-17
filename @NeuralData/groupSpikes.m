% function cellSpikeTimes = groupSpikes(this)
function cellSpikeTimes = groupSpikes(this)
    % Build a matrix of unique cell/shank combinations.
    nClusters = max(this.Spike.totclu);
    cellSpikeTimes = cell(nClusters, 1);

    % Group all of the clusters that are labeled the same. Also, convert from
    % index data to time data.
    for i = 1 : nClusters
        cellSpikeTimes{i} = this.Spike.res(this.Spike.totclu == i) / sampleRate(this);
    end

    this.data.spikeTrains = cellSpikeTimes;
end