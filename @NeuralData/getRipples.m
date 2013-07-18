function ripples = getRipples(this, rippleNums)
    if ~isfield(this.current, 'ripples')
        detectRipples(this);
    end

    if ~exist('rippleNums', 'var')
        rippleNums = (1 : size(this.current.ripples, 1));
    end

    ripples = this.current.ripples(rippleNums, :);
end