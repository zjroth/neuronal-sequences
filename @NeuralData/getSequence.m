% vSequence = getSequence(this, vTimeWindow, varargin)
function vSequence = getSequence(this, vTimeWindow, varargin)
    % Parse the named parameters.
    removeInterneurons = false;
    parseNamedParams();

    % Figure out the min/max index corresponding to the time window.
    nMinIndex = vTimeWindow(1) * sampleRate(this);
    nMaxIndex = vTimeWindow(2) * sampleRate(this);

    % The sequence of neuron firings is stored in two separate fields of
    % `this.Spike`. First, `this.Spike.res` has the firing times (indices) at
    % which spikes occur; however, these spike times seem not to be increasing
    % with respect to their corresponding indices. Next, the actual neuron that
    % spiked is stored in `this.Spike.totclu`; retrieve this list in the order
    % sorted by spike times.
    vIndices = find(nMinIndex < this.Spike.res & this.Spike.res < nMaxIndex);
    [~, vOrder] = sort(this.Spike.res(vIndices));
    vSequence = this.Spike.totclu(vIndices(vOrder));

    % Remove interneurons from this sequence if requested. This is only possible
    % if this object contains the appropriate reference to identified
    % interneurons.
    if removeInterneurons
        vInterneurons = getInterneurons(this);

        for i = 1 : length(vInterneurons)
            vSequence(vSequence == vInterneurons(i)) = [];
        end
    end
end