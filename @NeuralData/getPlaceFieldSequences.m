% cellSequences = getPlaceFieldSequences(this, varargin)
function cellSequences = getPlaceFieldSequences(this, varargin)
    mtxTimeWindows = getPlaceFieldIntervals(this);
    cellSequences = getSequences(this, mtxTimeWindows, varargin{:});
end
