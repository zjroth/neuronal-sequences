% mtxEvents = getEvents(this)
function cellEvents = getEvents(this, mtxTimeWindows, uknClassification)
    % The default event type is the empty string.
    if nargin < 3
        uknClassification = '';
    end

    nWindows = size(mtxTimeWindows, 1);
    cellEvents = cell(nWindows, 1);

    % Build the list of event types.
    if isa(uknClassification, 'cell')
        assert(length(uknClassification) == nWindows, ...
               'NeuralData.getEvents: classification parameter of incorrect size');
        cellEventTypes = uknClassification;
    elseif isa(uknClassification, 'char')
        cellEventTypes = cell(nWindows, 1);
        cellEventTypes(:) = {uknClassification};
    else
        error(['NeuralData.getEvents: classification parameter must be a ' ...
               'cell array or a string'])
    end

    % Retrieve the requested events.
    for i = 1 : nWindows
        cellEvents{i} = getEvent(this, mtxTimeWindows(i, :), cellEventTypes{i});
    end
end