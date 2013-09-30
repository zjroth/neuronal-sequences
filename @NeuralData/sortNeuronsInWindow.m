% vOrdering = sortNeuronsInWindow(this, vTimeWindow, varargin)
function vOrdering = sortNeuronsInWindow(this, vTimeWindow, varargin)
    dMinTime = vTimeWindow(1);
    dMaxTime = vTimeWindow(2);
    fcnRestrictToWindow = @(v) v(dMinTime <= v & v <= dMaxTime);

    cellSpikeTrains = cellfun(fcnRestrictToWindow, getSpikeTrains(this), ...
                              'UniformOutput', false);
    vOrdering = sortNeurons(cellSpikeTrains, varargin{:});
end