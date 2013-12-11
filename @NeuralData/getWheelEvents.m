% cellEvents = getWheelEvents(this)
function cellEvents = getWheelEvents(this)
    mtxIntervals = getWheelIntervals(this);
    cellEvents = getEvents(this, mtxIntervals, 'wheel');
end
