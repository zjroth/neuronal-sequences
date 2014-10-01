% [mtxTimeWindows, cellClassification] = getThetaIntervals(this, bSliding)
function [mtxTimeWindows, cellClassification] = getThetaIntervals(this, bSliding)
    if nargin < 2
        bSliding = false;
    end

    % Retrieve the intervals in which the animal is in one of the arms.
    [cellLeftOut, cellLeftIn] = getArmIntervals(this, 'left');
    [cellRightOut, cellRightIn] = getArmIntervals(this, 'right');
    cellWheel = getWheelIntervals(this);

    % If requested, use a sliding window instead.
    if bSliding
        dStep = 0.025 * sampleRate(this);

        cellLeftOut = slidingTheta(cellLeftOut, dStep);
        cellLeftIn = slidingTheta(cellLeftIn, dStep);
        cellRightOut = slidingTheta(cellRightOut, dStep);
        cellRightIn = slidingTheta(cellRightIn, dStep);
        cellWheel = slidingTheta(cellWheel, dStep);
    end

    mtxLeftOut = cell2mat(cellLeftOut);
    mtxLeftIn = cell2mat(cellLeftIn);
    mtxRightOut = cell2mat(cellRightOut);
    mtxRightIn = cell2mat(cellRightIn);
    mtxWheel = cell2mat(cellWheel);

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

% Generate sliding windows for the various intervals.
function cellSliding = slidingTheta(cellWindows, dStep)
    % dAvg = mean(diff(mtxWindows, [], 2));
    % getSlidingWindows = @(w) slidingWindow(w, dAvg, dStep);
    % mtxSliding = cell2mat(cellfun(getSlidingWindows, rows(mtxWindows), ...
    %                               'UniformOutput', false));

    getAvg = @(x) mean(diff(x, [], 2));
    getSlidingWindows = @(w) slidingWindow(w([1, end]), getAvg(w), dStep);
    cellSliding = cellfun(getSlidingWindows, cellWindows, ...
                          'UniformOutput', false);
end

function [cellOutbound, cellInbound] = getArmIntervals(this, strArm)
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
    nTrials = length(vTrials);
    cellOutbound = cell(nTrials, 1);
    cellInbound  = cell(nTrials, 1);

    for i = 1 : nTrials
        nTrial = vTrials(i);
        vPeakTimesOut = col(stctFile.trials{nTrial}.thetaPeak_tAmpl{1}(:, 1));
        vPeakTimesIn  = col(stctFile.trials{nTrial}.thetaPeak_tAmpl{3}(:, 1));

        cellOutbound{i} = [vPeakTimesOut(1 : end - 1), vPeakTimesOut(2 : end)];
        cellInbound{i} = [vPeakTimesIn(1 : end - 1), vPeakTimesIn(2 : end)];
    end
end

function cellIntervals = getWheelIntervals(this, strArm)
    strSuffix = '_DataStructure_mazeSection2_TrialType1_whlDirCW.mat';
    strFile = fullfile(this.baseFolder, [this.baseFileName strSuffix]);
    stctFile = load(strFile);

    vTrials = find(~cellfun(@isempty, stctFile.trials));
    nTrials = length(vTrials);
    cellIntervals = cell(nTrials, 1);

    for i = 1 : nTrials
        nTrial = vTrials(i);
        vPeakTimes = col(stctFile.trials{nTrial}.thetaPeak_tAmpl{1}(:, 1));
        cellIntervals{i} = [vPeakTimes(1 : end - 1), vPeakTimes(2 : end)];
    end
end
