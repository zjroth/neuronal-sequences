% mtxTimeWindows = getPlaceCellSequences(this)
function mtxTimeWindows = getPlaceFieldIntervals(this)
    % del = 1 (region-2)
    % whlL = 2 (region-1)
    % whlR = 3 (region-1)
    % armL = 4 (region-4)
    % armR = 5 (region-3)
    % armC = 6 (region-5)
    % rewL = 7 (region-7)
    % rewR = 8 (region-6)
    % rewC = 9 (region-8)
    % turnL = 10 (region-10)
    % turnR = 11 (region-9)

    % Retrieve the intervals in which the animal is in one of the arms.
    vMazeSect = this.getTrack('mazeSect');
    vIntervals = (vMazeSect == 4 | vMazeSect == 5);
    mtxIntervals = getIntervals(vIntervals);

    % If the animal is passing through an arm, then the area that it is in
    % immediately before entering the arm should be different from the area that
    % it enters immediately after leaving the arm. Additionally, the sections
    % that the animal moves to/from should be in the list of valid sections.
    vSectionBefore = vMazeSect(mtxIntervals(:, 1) - 1);
    vSectionAfter = vMazeSect(mtxIntervals(:, 2) + 1);

    vSurroundingSections = [7, 10, 8, 11];
    vIsValid = ...
        (vSectionBefore ~= vSectionAfter) ...
        & ismember(vSectionBefore, vSurroundingSections) ...
        & ismember(vSectionAfter, vSurroundingSections);

    mtxIntervals = mtxIntervals(vIsValid, :);

    % Now, simply convert the index data to time data.
    mtxTimeWindows = mtxIntervals / sampleRate(this);
end