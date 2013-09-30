% detectInterneurons(this)
function detectInterneurons(this)
    % The minimum firing rate of an interneuron (in Hertz).
    dMinFiringRate = 7;

    % Count the number of times that each cell fired.
    vSpikeCounts = accumarray(col(this.Spike.totclu), 1);

    % To compute the firing rates, divide the total number of spikes by the
    % total number of samples; convert this to Hertz by multiplying by the
    % sample rate.
    vFiringRates = vSpikeCounts / length(this.Track.xPix) * sampleRate(this);

    % Now, simply extract the cells that have at least the minimum specified
    % firing rate. Store the interneurons in this object so that they don't
    % need to be detected again.
    this.data.interneurons = find(vFiringRates > dMinFiringRate);
end