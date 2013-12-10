% cellTrains = getSpikeTrains(this, bRemoveInterneurons)
function cellTrains = getSpikeTrains(this, bRemoveInterneurons)
    if nargin < 2
        bRemoveInterneurons = true;
    end

    % Ensure that the spike trains have already been grouped.
    if ~isfield(this.data, 'spikeTrains')
        groupSpikes(this);
    end

    % Simply return the already-grouped spike trains.
    cellTrains = this.data.spikeTrains;

    % Interneurons are distracting. Remove them.
    if bRemoveInterneurons
        cellTrains(getInterneurons(this)) = {[]};
    end
end
