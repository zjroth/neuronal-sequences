% mtxEvents = getEvents(this)
function cellEvents = getEvents(this, mtxTimeWindows, uknClassification)
    if nargin < 3
        uknClassification = 'none';
    end

    nWindows = size(mtxTimeWindows, 1);

    if isa(uknClassification, 'cell')
        assert(length(uknClassification) == nWindows, ...
               'NeuralData.getEvents: classification parameter of incorrect size');
        cellClassification = uknClassification;
    elseif isa(uknClassification, 'char')
        cellClassification = cell(nWindows, 1);
        cellClassification(:) = {uknClassification};
    end

    for i = 1 : nWindows
        cellEvents{i} = getEvent(this, mtxTimeWindows(i, :), cellClassification{i});
    end
end