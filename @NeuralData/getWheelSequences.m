% cellSequences = getWheelSequences(this, varargin)
function cellSequences = getWheelSequences(this, varargin)
    mtxIntervals = getIntervals(logical(this.Laps.WhlSpeedCW));
    mtxTimeWindows = mtxIntervals / sampleRate(this);

    cellSequences = getSequences(this, mtxTimeWindows, varargin{:});
end