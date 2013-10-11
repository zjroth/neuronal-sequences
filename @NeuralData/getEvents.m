% mtxEvents = getEvents(this)
function [mtxEvents, nRipples, nWheelEvents, nPlaceFieldEvents] = ...
    getEvents(this)

    % Retrieve the ripple events.
    mtxRipples = getRipples(this);
    nRipples = size(mtxRipples, 1);

    % Retrieve the wheel events.
    mtxWheelEvents = getWheelIntervals(this);
    nWheelEvents = size(mtxWheelEvents, 1);

    % Retrieve the place-field events.
    mtxPlaceFieldEvents = getPlaceFieldIntervals(this);
    nPlaceFieldEvents = size(mtxPlaceFieldEvents, 1);

    % Build the entire matrix of events.
    mtxEvents = [ mtxRipples([1, 2]); ...
                  mtxWheelEvents;     ...
                  mtxPlaceFieldEvents ...
                ];
end