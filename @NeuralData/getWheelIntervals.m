% mtxTimeWindows = getWheelIntervals(this)
function mtxTimeWindows = getWheelIntervals(this)
    mtxIntervals = getIntervals(logical(this.getLaps('WhlSpeedCW')));
    mtxTimeWindows = mtxIntervals / sampleRate(this);
end
