function orderings = sortNeurons(this)
    ripples = this.getRipples();
    spikeTrains = this.getSpikeTrains();

    nNeurons = length(spikeTrains);
    orderings = cell(nNeurons, 1);

    for i = 1 : size(ripples, 1)
        ripple = ripples(i, :);
        centerOfMass = zeros(nNeurons, 1);

        for j = 1 : nNeurons
            train = spikeTrains{j};
            centerOfMass(j) = mean(train(train >= ripple(1) & train <= ripple(3)));
        end

        [~, ordering] = sort(centerOfMass);
        orderings{i} = ordering(~isnan(ordering));
    end
end