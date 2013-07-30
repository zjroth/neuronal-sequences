function rippleSpikeMatrix = getRippleSpikeMatrix(this)
    if ~isfield(this.current, 'rippleSpikeMatrix')
        computeRippleSpikeMatrix(this);
    end

    rippleSpikeMatrix = this.current.rippleSpikeMatrix;
end