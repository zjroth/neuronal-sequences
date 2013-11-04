%
% USAGE:
%
%    cellSequences = getSequences(this, mtxTimeWindows, bRemoveInterneurons)
%
% DESCRIPTION:
%
%    Get the sequences of neuron firings in the given time windows
%
% ARGUMENTS:
%
%    mtxTimeWindows
%
%       A matrix with 2 columns, each row of which represents a time window
%       from which to extract a sequence
%
%    bRemoveInterneurons (default: true)
%
%       A boolean specifying whether the returned sequence should contain
%       interneurons
%
% RETURNS:
%
%    cellSequences
%
%       The desired sequences of firings
%
% NOTE:
%
%    This simply loops through the given set of time windows, calls the
%    method `getSequence` on each one, and concatenates the results into a
%    cell array.
%
function cellSequences = getSequences(this, mtxTimeWindows, bRemoveInterneurons)
    % Retrieve the number of time windows, and initialize the return variable.
    nWindows = size(mtxTimeWindows, 1);
    cellSequences = cell(nWindows, 1);

    % Loop through the windows to get the sequence for each.
    for i = 1 : nWindows
        vWindow = mtxTimeWindows(i, :);
        cellSequences{i} = this.getSequence(vWindow, varargin{:});
    end
end