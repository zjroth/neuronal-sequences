% objEvent = getEvent(this, vTimeWindow, strType)
function objEvent = getEvent(this, vTimeWindow, strType)
    [vSequence, vTimes] = getSequence(this, vTimeWindow);

    if nargin == 3
        objEvent = Event(vTimeWindow, vTimes, vSequence, strType);
    else
        objEvent = Event(vTimeWindow, vTimes, vSequence);
    end
end
