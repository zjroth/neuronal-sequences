% cellEvents = getThetaEvents(this)
function cellEvents = getThetaEvents(this)
    [mtxIntervals, cellClassification] = getThetaIntervals(this)
    cellEvents = getEvents(this, mtxIntervals, cellClassification);
end
