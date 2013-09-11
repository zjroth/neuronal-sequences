% vSequence = getRippleSequence(this, nRipple, varargin)
function vSequence = getRippleSequence(this, nRipple, varargin)
    vRipple = this.getRipples(nRipple);
    vSequence = getSequence(this, vRipple([1, 3]), varargin{:});
end