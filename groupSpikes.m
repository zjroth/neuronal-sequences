% function spikeTimes = groupSpikes(spikesStruct)
function clusterSpikeTimes = groupSpikes(spikesStruct)
    % Build a matrix of unique cell/shank combinations.
    numClusters = max(spikesStruct.totclu);
    clusterSpikeTimes = cell(numClusters, 1);

    for i = 1 : numClusters
        clusterSpikeTimes{i} = spikesStruct.res(spikesStruct.totclu == i);
    end
end