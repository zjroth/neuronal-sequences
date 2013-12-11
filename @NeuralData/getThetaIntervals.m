function [mtxTimeWindows, cellClassification] = getThetaIntervals(this)
    % Retrieve the intervals in which the animal is in one of the arms.
    [mtxLeftOut, mtxLeftIn] = getArmIntervals(this, 'left');
    [mtxRightOut, mtxRightIn] = getArmIntervals(this, 'right');
    mtxWheel = getWheelIntervals(this);

    % Join the above lists into a master list and save the classification for
    % each event.
    mtxIntervals = [mtxLeftOut;  ...
                    mtxLeftIn; ...
                    mtxRightOut; ...
                    mtxRightIn; ...
                    mtxWheel];

    cellClassification = vertcat( ...
        repmat({'theta/arm/left/outbound'},  size(mtxLeftOut, 1), 1), ...
        repmat({'theta/arm/left/inbound'},   size(mtxLeftIn, 1), 1), ...
        repmat({'theta/arm/right/outbound'}, size(mtxRightOut, 1), 1), ...
        repmat({'theta/arm/right/inbound'},  size(mtxRightIn, 1), 1), ...
        repmat({'theta/wheel'},              size(mtxWheel, 1), 1));

    % Now, simply convert the index data to time data.
    mtxTimeWindows = mtxIntervals / sampleRate(this);
end

function [mtxOutbound, mtxInbound] = getArmIntervals(this, strArm)
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

    mtxOutbound = [];
    mtxInbound  = [];

    for i = 1 : length(vTrials)
        nTrial = vTrials(i);
        vPeakTimesOut = col(stctFile.trials{nTrial}.thetaPeak_tAmpl{1}(:, 1));
        vPeakTimesIn  = col(stctFile.trials{nTrial}.thetaPeak_tAmpl{3}(:, 1));

        mtxOutbound = [ ...
            mtxOutbound; ...
            vPeakTimesOut(1 : end - 1), vPeakTimesOut(2 : end)];
        mtxInbound = [ ...
            mtxInbound; ...
            vPeakTimesIn(1 : end - 1), vPeakTimesIn(2 : end)];
    end
end

function mtxIntervals = getWheelIntervals(this, strArm)
    strSuffix = '_DataStructure_mazeSection2_TrialType1_whlDirCW.mat';
    strFile = fullfile(this.baseFolder, [this.baseFileName strSuffix]);
    stctFile = load(strFile);

    vTrials = find(~cellfun(@isempty, stctFile.trials));

    mtxIntervals = [];

    for i = 1 : length(vTrials)
        nTrial = vTrials(i);
        vPeakTimes = col(stctFile.trials{nTrial}.thetaPeak_tAmpl{1}(:, 1));

        mtxIntervals = [ ...
            mtxIntervals; ...
            vPeakTimes(1 : end - 1), vPeakTimes(2 : end)];
    end
end
