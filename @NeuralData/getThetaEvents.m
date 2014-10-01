% cellEvents = getThetaEvents(this, bSliding)
function cellEvents = getThetaEvents(this, bSliding)
    if nargin < 2
        bSliding = false;
    end

    [mtxIntervals, cellClassification] = getThetaIntervals(this, bSliding);
    cellEvents = getEvents(this, mtxIntervals, cellClassification);
end
