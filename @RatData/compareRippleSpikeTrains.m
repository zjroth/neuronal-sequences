% compareRippleSpikeTrains(this, nSeqX, nSeqY)
function compareRippleSpikeTrains(this, nSeqX, nSeqY, vActiveNeurons)
    % For displaying the sequences, we'll need to know which recording each
    % sequence belongs to along with the corresponding local sequence/ripple
    % number.
    [strConditionX, nRippleX] = this.identifyRipple(nSeqX);
    [strConditionY, nRippleY] = this.identifyRipple(nSeqY);

    % compareSpikeTrains(this, strConditionX, vTimeWindowX, strConditionY, ...
    %                    vTimeWindowY, vActiveNeurons);

    % Retrieve the ideal sort order for sequence x, and retrieve the neurons
    % that are active in sequence y. The neuron order is the order given by
    % the ideal order for sequence x with the restriction that all neurons
    % must also belong to sequence y.
    vOrderForX = this.sortNeuronsForRipple(nSeqX);
    vOrderForY = this.sortNeuronsForRipple(nSeqY);
    vInX = intersect(vOrderForX, vActiveNeurons);
    vInY = intersect(vOrderForY, vActiveNeurons);
    vNeuronOrderX = intersect(vOrderForX, vInY, 'stable');
    vNeuronOrderY = intersect(vOrderForY, vInX, 'stable');

    % Plot the sequences with the above-found sorting order.
    figure();

    subplot(2, 2, 1);
    this.(strConditionX).plotRippleSpikeTrains( ...
        nRippleX, 'vNeuronOrder', vNeuronOrderX, 'bRemoveInterneurons', true);
    title(['Sequence ' num2str(nSeqX) ' (ideal ordering)']);

    subplot(2, 2, 2);
    this.(strConditionX).plotRippleSpikeTrains( ...
        nRippleX, 'vNeuronOrder', vNeuronOrderY, 'bRemoveInterneurons', true);
    title(['Sequence ' num2str(nSeqX) ' (ideal ordering for sequence ' num2str(nSeqY) ')']);

    subplot(2, 2, 3);
    this.(strConditionY).plotRippleSpikeTrains( ...
        nRippleY, 'vNeuronOrder', vNeuronOrderX, 'bRemoveInterneurons', true);
    title(['Sequence ' num2str(nSeqY) ' (ideal ordering for sequence ' num2str(nSeqX) ')']);

    subplot(2, 2, 4);
    this.(strConditionY).plotRippleSpikeTrains( ...
        nRippleY, 'vNeuronOrder', vNeuronOrderY, 'bRemoveInterneurons', true);
    title(['Sequence ' num2str(nSeqY) ' (ideal ordering)']);
end