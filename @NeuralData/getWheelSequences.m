% cellSequences = getWheelSequences(this, varargin)
function cellSequences = getWheelSequences(this, varargin)
    mtxTimeWindows = getWheelIntervals(this);
    cellSequences = getSequences(this, mtxTimeWindows, varargin{:});
end