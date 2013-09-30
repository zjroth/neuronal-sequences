% cellTrains = getSpikeTrains(this, bRemoveInterneurons)
function cellTrains = getSpikeTrains(this, bRemoveInterneurons)
    if nargin < 2
        bRemoveInterneurons = false;
    end

    % Ensure that the spike trains have already been grouped.
    if ~isfield(this.data, 'spikeTrains')
        groupSpikes(this);
    end

    % Simply return the already-grouped spike trains.
    cellTrains = this.data.spikeTrains;

    % Interneurons are distracting. Remove them.
    if bRemoveInterneurons && isfield(this.parameters, 'interneurons')
        cellTrains(this.parameters.interneurons) = {[]};
    end
end