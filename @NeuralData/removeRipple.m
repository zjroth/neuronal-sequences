function removeRipple(this, nRipple)
    if ~isfield(this.current, 'ripples')
        error(['NeuralData.removeRipple: ripples must be detected before a' ...
            'ripple can be removed']);
    end

    this.current.ripples(nRipple, :) = [];
end