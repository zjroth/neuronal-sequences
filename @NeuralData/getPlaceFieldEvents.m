% cellEvents = getPlaceFieldEvents(this)
function cellEvents = getPlaceFieldEvents(this)
    [mtxIntervals, cellClassification] = getPlaceFieldIntervals(this);
    cellEvents = getEvents(this, mtxIntervals, cellClassification);
end
