% cellSequence = getSequences(this, mtxTimeWindows, varargin)
function cellSequences = getSequences(this, mtxTimeWindows, varargin)
    % Retrieve the number of time windows, and initialize the return variable.
    nWindows = size(mtxTimeWindows, 1);
    cellSequences = cell(nWindows, 1);

    % Loop through the windows to get the sequence for each.
    for i = 1 : nWindows
        vWindow = mtxTimeWindows(i, :);
        cellSequences{i} = this.getSequence(vWindow, varargin{:});
    end
end