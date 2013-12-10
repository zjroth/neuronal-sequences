function cellTrains = sortWheelCells(this)
    cellTrains = getSpikeTrains(this, false);

    % Simply return the already-grouped spike trains.
    cellTrains = this.data.spikeTrains;

    % Interneurons are distracting. Remove them.
    if bRemoveInterneurons
        cellTrains(getInterneurons(this)) = {[]};
    end
end
