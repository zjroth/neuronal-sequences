% [bSuccess, vPartition] = partitionSimilar(mtxWeighted)
function [bSuccess, vPartition] = partitionSimilar(mtxWeighted)
    % Ensure that the argument is actually symmetric.
    assert(isequal(mtxWeighted, mtxWeighted.'), ...
        'partitionSimilar: an adjacency matrix must be symmetric');

    % Retrieve the number of vertices in the graph, and convert the weighted
    % adjacency matrix into a signed and an unsigned adjacency matrix.
    nVerts = size(mtxWeighted, 1);
    mtxAdjSigned = sign(mtxWeighted);
    mtxAdj = logical(mtxAdjSigned);

    % Initialize the values for tracking the progress of the algorithm. We need
    % to keep track of which partion each vertex belongs to, which vertices have
    % been visited, and which vertices remain in the "queue".
    % NOTE: This "queue" is not an actual queue (first in, first out), but it
    % does keep track of which vertices can be visited by traversing an edge
    % connected to an already-visited vertex.
    bSuccess = true;
    vPartition = zeros(nVerts, 1);
    vQueue = false(nVerts, 1);
    vVisited = false(nVerts, 1);

    % If any vertex remains to be visited...
    while ~all(vVisited) && bSuccess
        % ...add the first unvisited vertex to the queue and place it in one of
        % the partitions.
        nCurrVertex = find(~vVisited, 1);
        nCurrPartition = 1;
        vPartition(nCurrVertex) = nCurrPartition;
        vQueue(nCurrVertex) = true;

        % Loop through the "queue".
        while any(vQueue) && bSuccess
            % Get the current vertex to process, say that we've now visited this
            % vertex, and remove it from the queue. Since this vertex is in the
            % queue, it should already be in one of the partitions; find which one.
            nCurrVertex = find(vQueue, 1);
            vVisited(nCurrVertex) = true;
            vQueue(nCurrVertex) = false;
            nCurrPartition = vPartition(nCurrVertex);

            % Check to see that the neighborhood of the current vertex can be placed
            % into the other partition.
            vAdj = mtxAdj(:, nCurrVertex);
            vAdjSigned = mtxAdjSigned(:, nCurrVertex);
            vSuggestedPartition = nCurrPartition * vAdjSigned;

            % If any of the suggested partions disagree with the previously-set
            % partition, then this graph cannot be partitioned.
            if any(vSuggestedPartition .* vPartition == -1)
                bSuccess = false;
                vPartition = [];
            else
                % ...otherwise, add the suggested partitioning to the current
                % partitioning.
                vPartition(vAdj) = vSuggestedPartition(vAdj);

                % Update the queue. Something should be in the queue if it is
                % currently in the queue or it is in the neighborhood of the current
                % vertex and has not yet been visited.
                vQueue = vQueue | (vAdj & ~vVisited);
            end
        end
    end
end