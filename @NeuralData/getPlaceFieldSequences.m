% cellSequences = getPlaceCellSequences(this, varargin)
function cellSequences = getPlaceCellSequences(this, varargin)
    mtxTimeWindows = getPlaceFieldIntervals(this);
    cellSequences = getSequences(this, mtxTimeWindows, varargin{:});
end