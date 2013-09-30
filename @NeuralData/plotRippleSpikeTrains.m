% plotRippleSpikeTrains(this, nRipple, varargin)
function plotRippleSpikeTrains(this, nRipple, varargin)
    vRipple = getRipples(this, nRipple);
    vTimeWindow = vRipple([1, 3]);
    plotSpikeTrains(this, vTimeWindow, varargin{:});
end
