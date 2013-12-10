% mtxEvents = getEvents(this)
function cellEvents = getEvents(this, mtxTimeWindows)
    for i = 1 : size(mtxTimeWindows, 1)
        cellEvents{i} = getEvent(this, mtxTimeWindows(i, :));
    end
end