% vOrder = sortNeuronsForRipple(this, nRipple, varargin)
function vOrder = sortNeuronsForRipple(this, nRipple, varargin)
    [strSection, nLocalRipple] = identifyRipple(this, nRipple);
    vOrder = sortNeuronsForRipple(this.(strSection), nLocalRipple, varargin{:});
end
