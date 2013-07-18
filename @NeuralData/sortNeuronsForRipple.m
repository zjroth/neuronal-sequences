function ordering = sortNeuronsForRipple(this, rippleNumber, varargin)
    restrictToActive = true;
    parseNamedParams();

    assert(isscalar(rippleNumber));

    ripple = this.getRipples(rippleNumber);
    spikeTrains = this.getSpikeTrains();

    nNeurons = length(spikeTrains);
    centersOfMass = zeros(nNeurons, 1);

    for j = 1 : nNeurons
        train = spikeTrains{j};
        train = train(ripple(1) <= train & train <= ripple(3));
        centersOfMass(j) = mean(train);
    end

    [~, ordering] = sort(centersOfMass);

    if restrictToActive
        ordering = ordering(1 : nnz(~isnan(centersOfMass)));
    end
end