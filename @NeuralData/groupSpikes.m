% function spikeTimes = groupSpikes(spikesStruct)
function clusterSpikeTimes = groupSpikes()
    % Build a matrix of unique cell/shank combinations.
    numClusters = max(this.Spikes.totclu);
    clusterSpikeTimes = cell(numClusters, 1);

    for i = 1 : numClusters
        clusterSpikeTimes{i} = this.Spikes.res(this.Spikes.totclu == i);
    end
end