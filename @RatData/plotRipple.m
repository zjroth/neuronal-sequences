% plotRipple(this, nRipple, varargin)
function plotRipple(this, nRipple, varargin)
    [strSection, nLocalRipple] = identifyRipple(this, nRipple);
    plotRipple(this.(strSection), nLocalRipple, varargin{:});
end