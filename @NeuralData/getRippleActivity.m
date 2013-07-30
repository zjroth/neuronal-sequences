function activeNeurons = getRippleActivity(this, nRipple)
    ripple = this.getRipples(nRipple);
    spikeTrains = this.getSpikeTrains();

    minTime = ripple(1);
    maxTime = ripple(3);

    fcn = @(v) nnz(v(minTime <= v & v <= maxTime));
    activeNeurons = cellfun(fcn, spikeTrains);
end