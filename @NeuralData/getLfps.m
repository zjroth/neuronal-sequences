% function objLfps = getLfps(this)
function objLfps = getLfps(this)
    if isempty(this.currentLfps)
        this.loadChannels();
    end

    if ~isfield(this.current, 'lfpTriple')
        mtxLfps = this.currentLfps;
        mtxLfps = bsxfun(@minus, mtxLfps, mean(mtxLfps, 1));
        vTimes = (0 : size(mtxLfps, 1) - 1) / rawSampleRate(this);
        this.current.lfpTriple = TimeSeries(mtxLfps, vTimes);
    end

    objLfps = this.current.lfpTriple;
end