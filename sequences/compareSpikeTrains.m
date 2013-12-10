% - build a cell array cellTrainCollns of collections of spike trains
% - build a matrix of event times
% - build a vector vColln mapping events to the corresponding spike-train
%   collection number
% - Call plotSpikeTrains(cellTrainCollns(vColln(x)), vEvents(x, :)



% compareSpikeTrains(this, strCondX, vTimeWindowX, strCondY, vTimeWindowY)
function compareSpikeTrains(cellTrainCollns, mtxEvents, vCollnNums, ...
                            nX, nY, vActiveNeurons)
    cellXTrains = cellTrainCollns{vCollnNums(nX)};
    cellYTrains = cellTrainCollns{vCollnNums(nY)};

    vTimeWindowX = mtxEvents(nX, :);
    vTimeWindowY = mtxEvents(nY, :);

    % Retrieve the ideal sort order for sequence x, and retrieve the neurons
    % that are active in sequence y. The neuron order is the order given by
    % the ideal order for sequence x with the restriction that all neurons
    % must also belong to sequence y.
    vOrderForX = sortNeuronsInWindow(cellXTrains, vTimeWindowX);
    vOrderForY = sortNeuronsInWindow(cellYTrains, vTimeWindowY);
    vInX = intersect(vOrderForX, vActiveNeurons);
    vInY = intersect(vOrderForY, vActiveNeurons);
    vNeuronOrderX = intersect(vOrderForX, vInY, 'stable');
    vNeuronOrderY = intersect(vOrderForY, vInX, 'stable');

    % Plot the sequences with the above-found sorting order.
    figure();

    subplot(2, 2, 1);
    plotSpikeTrains(cellXTrains, ...
        vTimeWindowX, vNeuronOrderX, 'bRemoveInterneurons', true);
    title('Sequence 1 (ideal ordering)');

    subplot(2, 2, 2);
    plotSpikeTrains(cellXTrains, ...
        vTimeWindowX, vNeuronOrderY, 'bRemoveInterneurons', true);
    title('Sequence 1 (ideal ordering for sequence 2)');

    subplot(2, 2, 3);
    plotSpikeTrains(cellYTrains, ...
        vTimeWindowY, vNeuronOrderX, 'bRemoveInterneurons', true);
    title('Sequence 2 (ideal ordering for sequence 1)');

    subplot(2, 2, 4);
    plotSpikeTrains(cellYTrains, ...
        vTimeWindowY, vNeuronOrderY, 'bRemoveInterneurons', true);
    title('Sequence 2 (ideal ordering)');
end