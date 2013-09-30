% vOrdering = sortNeuronsForRipple(this, nRipple, varargin)
function vOrdering = sortNeuronsForRipple(this, nRipple, varargin)
    vRipple = this.getRipples(nRipple);
    vTimeWindow = vRipple([1, 3]);

    vOrdering = sortNeuronsInWindow(this, vTimeWindow, varargin{:});
end