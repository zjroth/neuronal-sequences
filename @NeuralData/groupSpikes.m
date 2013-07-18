% function clusterSpikeTimes = groupSpikes(this)
function clusterSpikeTimes = groupSpikes(this)
    % Build a matrix of unique cell/shank combinations.
    numClusters = max(this.Spike.totclu);
    clusterSpikeTimes = cell(numClusters, 1);

    for i = 1 : numClusters
        clusterSpikeTimes{i} = this.Spike.res(this.Spike.totclu == i);
    end

    this.current.spikeTrains = clusterSpikeTimes;
end