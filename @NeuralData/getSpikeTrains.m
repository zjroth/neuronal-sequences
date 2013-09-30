function cellTrains = getSpikeTrains(this, bRemoveInterneurons)
    if nargin < 2
        bRemoveInterneurons = false;
    end

    if ~isfield(this.current, 'spikeTrains')
        groupSpikes(this);
    end

    cellTrains = this.current.spikeTrains;

    % Interneurons are distracting. Remove them.
    if bRemoveInterneurons && isfield(this.parameters, 'interneurons')
        cellTrains(this.parameters.interneurons) = {[]};
    end
end