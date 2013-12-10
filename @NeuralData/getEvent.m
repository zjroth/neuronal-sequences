% objEvent = getEvent(this, vTimeWindow, strType)
function objEvent = getEvent(this, vTimeWindow, strType)
    [vSequence, vTimes] = getSequence(this, vTimeWindow);
    objEvent = Event(vTimeWindow, vTimes, vSequence);
end
