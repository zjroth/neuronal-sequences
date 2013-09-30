% cellSequences = getPlaceCellSequences(this, varargin)
function cellSequences = getPlaceCellSequences(this, varargin)
    % (145 < objRatData.pre.Track.xPix) & (objRatData.pre.Track.xPix < 583)
    % (160 < objRatData.musc.Track.xPix) & (objRatData.musc.Track.xPix < 550)

    vIntervals = (160 < this.Track.xPix) & (this.Track.xPix < 550);
    mtxIntervals = getIntervals(vIntervals);
    mtxTimeWindows = mtxIntervals / sampleRate(this);

    cellSequences = getSequences(this, mtxTimeWindows, varargin{:});
end