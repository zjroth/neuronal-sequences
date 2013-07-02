% function spikeTimes = groupSpikes(spikesStruct)
function [spikeTimes, cellNumbers] = groupSpikes(spikesStruct)
    % Build a matrix of unique cell/shank combinations.
    numClusters = max(spikesStruct.totclu);
    spikeTimes = cell(numClusters, 1);

    for i = 1 : numClusters
        spikeTimes{i} = spikesStruct.res(spikesStruct.totclu == i);
    end
end