% vNearest = getNearestRipples(this, nRipple)
function vNearest = getNearestRipples(this, nRipple)
    % Retrieve a matrix containing the number of spikes contained in each
    % ripple (columns) for each neuron (rows).
    mtxSpikesPerRipple = getRippleSpikeMatrix(this);

    % Consider two ripples to share a neuron if both ripples contain multiple
    % spikes for that neuron.
    mtxMultipleSpikes = double(mtxSpikesPerRipple > 0);
    vNumSharedNeurons = mtxMultipleSpikes(:, nRipple)' * mtxMultipleSpikes;

    % The "nearest" ripples are the ones that share the most neurons with this
    % ripple.
    [~, vNearest] = sort(vNumSharedNeurons, 'descend');
end