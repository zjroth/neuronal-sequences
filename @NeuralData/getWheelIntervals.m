% mtxTimeWindows = getWheelIntervals(this)
function mtxTimeWindows = getWheelIntervals(this)
    mtxIntervals = getIntervals(logical(this.Laps.WhlSpeedCW));
    mtxTimeWindows = mtxIntervals / sampleRate(this);
end