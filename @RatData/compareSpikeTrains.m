% compareSpikeTrains(this, strCondX, vTimeWindowX, strCondY, vTimeWindowY)
function compareSpikeTrains(this, strCondX, vTimeWindowX, strCondY, ...
                            vTimeWindowY, vActiveNeurons)
    % Retrieve the ideal sort order for sequence x, and retrieve the neurons
    % that are active in sequence y. The neuron order is the order given by
    % the ideal order for sequence x with the restriction that all neurons
    % must also belong to sequence y.
    vOrderForX = sortNeuronsInWindow(this.(strCondX), vTimeWindowX);
    vOrderForY = sortNeuronsInWindow(this.(strCondY), vTimeWindowY);
    vInX = intersect(vOrderForX, vActiveNeurons);
    vInY = intersect(vOrderForY, vActiveNeurons);
    vNeuronOrderX = intersect(vOrderForX, vInY, 'stable');
    vNeuronOrderY = intersect(vOrderForY, vInX, 'stable');

    % Plot the sequences with the above-found sorting order.
    figure();

    subplot(2, 2, 1);
    this.(strCondX).plotSpikeTrains( ...
        vTimeWindowX, 'vNeuronOrder', vNeuronOrderX, 'bRemoveInterneurons', true);
    title('Sequence 1 (ideal ordering)');

    subplot(2, 2, 2);
    this.(strCondX).plotSpikeTrains( ...
        vTimeWindowX, 'vNeuronOrder', vNeuronOrderY, 'bRemoveInterneurons', true);
    title('Sequence 1 (ideal ordering for sequence 2)');

    subplot(2, 2, 3);
    this.(strCondY).plotSpikeTrains( ...
        vTimeWindowY, 'vNeuronOrder', vNeuronOrderX, 'bRemoveInterneurons', true);
    title('Sequence 2 (ideal ordering for sequence 1)');

    subplot(2, 2, 4);
    this.(strCondY).plotSpikeTrains( ...
        vTimeWindowY, 'vNeuronOrder', vNeuronOrderY, 'bRemoveInterneurons', true);
    title('Sequence 2 (ideal ordering)');
end