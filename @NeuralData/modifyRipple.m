function modifyRipple(this, nRipple, nStartTime, nEndTime)
    objSharpWave = getSharpWave(this);
    [~, nPeakTime] = max(subseries(objSharpWave, nStartTime, nEndTime));
    this.current.ripples(nRipple, :) = [nStartTime, nPeakTime, nEndTime];
end
