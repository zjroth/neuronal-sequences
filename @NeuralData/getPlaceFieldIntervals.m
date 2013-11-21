% mtxTimeWindows = getPlaceCellSequences(this)
function [mtxTimeWindows, cellClassification] = getPlaceFieldIntervals(this)
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

    [mtxLeftOut, mtxLeftBack] = getArmIntervals(this, 'left');
    [mtxRightOut, mtxRightBack] = getArmIntervals(this, 'right');

    % Join the above lists into a master list and save the classification for
    % each event.
    mtxIntervals = [mtxLeftOut;  ...
                    mtxLeftBack; ...
                    mtxRightOut; ...
                    mtxRightBack];

    cellClassification = vertcat( ...
        repmat({'left/outbound'}, size(mtxLeftOut, 1), 1), ...
        repmat({'left/inbound'}, size(mtxLeftOut, 1), 1), ...
        repmat({'right/outbound'}, size(mtxLeftOut, 1), 1), ...
        repmat({'right/inbound'}, size(mtxLeftOut, 1), 1));

    % Now, simply convert the index data to time data.
    mtxTimeWindows = mtxIntervals / sampleRate(this);
end

function [mtxOut, mtxBack] = getArmIntervals(this, strArm)
    if strcmp(strArm, 'left')
        nSection = 4;
    elseif strcmp(strArm, 'right')
        nSection = 5;
    else
        error();
    end

    strSuffix = ['_DataStructure_mazeSection' num2str(nSection) '_TypeMaze1.mat'];
    strFile = fullfile(this.baseFolder, [this.baseFileName strSuffix]);
    stctFile = load(strFile);

    vTrials = find(~cellfun(@isempty, stctFile.trials));

    for i = 1 : length(vTrials)
        nTrial = vTrials(i);

        mtxOut(i, :) = [stctFile.trials{nTrial}.lfpIndStart(1), ...
                        stctFile.trials{nTrial}.lfpIndEnd(1)];
        mtxBack(i, :) = [stctFile.trials{nTrial}.lfpIndStart(3), ...
                         stctFile.trials{nTrial}.lfpIndEnd(3)];
    end
end