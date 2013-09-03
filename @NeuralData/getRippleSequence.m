% vSequence = getRippleSequence(this, nRipple, varargin)
function vSequence = getRippleSequence(this, nRipple, varargin)
    % Parse the named parameters.
    removeInterneurons = false;
    parseNamedParams();

    % Retrieve the ripple for which we are extracting a sequence, and figure out
    % the min/max index corresponding to the ripple window.
    vRipple = this.getRipples(nRipple);
    nMinIndex = vRipple(1) * sampleRate(this);
    nMaxIndex = vRipple(3) * sampleRate(this);

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
    if removeInterneurons && isfield(this.parameters, 'interneurons')
        vInterneurons = this.parameters.interneurons;

        for i = 1 : length(vInterneurons)
            vSequence(vSequence == vInterneurons(i)) = [];
        end
    end
end