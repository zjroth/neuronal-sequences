function computeRippleSpikeMatrix(this)
    % Get the current ripples and spike trains.
    ripples = getRipples(this);
    spikeTrains = getSpikeTrains(this);

    % Store the number of ripples, the number of neurons being used, and
    % initialize the return value.
    nNeurons = length(spikeTrains);
    nRipples = size(ripples, 1);
    rippleSpikeMatrix = zeros(nNeurons, nRipples);

    % Build the matrix containing the number of spikes per ripple.
    for i = 1 : nRipples
        s = ripples(i, 1);
        e = ripples(i, 3);

        fcn = @(t) sum(t >= s & t <= e);
        rippleSpikeMatrix(:, i) = cellfun(fcn, spikeTrains);

        %for j = 1 : nNeurons
        %    train = spikeTrains{j};
        %    rippleSpikeMatrix(j, i) = nnz(train >= s & train <= e);
        %end
    end

    this.current.rippleSpikeMatrix = rippleSpikeMatrix;
end