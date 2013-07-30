% intervals = getIntervals(v, asCellArray)
function intervals = getIntervals(v, asCellArray)
    % By default, do not return a cell array.
    if nargin < 2
       asCellArray = false;
    end

    % We want to work with a binary column vector. Once we have that, find the
    % indices of the jumps in that vector (i.e., basically the first index of
    % each interval). Note that the `+1` is there due to `diff` returning a
    % vector that is one shorter than its input vector.
    vect = col(v ~= 0);
    jumps = find(diff(vect)) + 1;

    % The first interval starts at index one; the rest start at the indices in
    % `jumps`. The last interval ends at the last index of `vect`; the rest end
    % immediately before the indices in `jumps`.
    starts = [1; jumps(1 : end)];
    ends = [jumps(1 : end) - 1; length(vect)];

    % Now, simply piece the starting indices and the ending indices together to
    % get the matrix where each row represents an interval.
    intervals = [starts, ends];

    % We only want the intervals where vect is true. Since we're working with a
    % binary vector, every other interval is true.
    if vect(1)
        intervals = intervals(1 : 2 : end, :);
    else
        intervals = intervals(2 : 2 : end, :);
    end

    % If requested, return a cell array where each entry is the full list of
    % indices for an interval.
    if asCellArray
        intervals = arrayfun(@colon, starts, ends, 'Uniform', false);
    end
end
