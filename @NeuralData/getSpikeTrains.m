function trains = getSpikeTrains(this)
    if ~isfield(this.current, 'spikeTrains')
        groupSpikes(this);
    end

    trains = this.current.spikeTrains;
end