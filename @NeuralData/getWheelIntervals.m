% mtxTimeWindows = getWheelIntervals(this)
function mtxTimeWindows = getWheelIntervals(this)
    strSuffix = '_DataStructure_mazeSection2_TrialType1_whlDirCW.mat';
    strFile = fullfile(this.baseFolder, [this.baseFileName strSuffix]);
    stctFile = load(strFile);

    vTrials = find(~cellfun(@isempty, stctFile.trials));

    for i = 1 : length(vTrials)
        nTrial = vTrials(i);

        mtxIntervals(i, :) = [stctFile.trials{nTrial}.lfpIndStart, ...
                              stctFile.trials{nTrial}.lfpIndEnd];
    end

    mtxTimeWindows = mtxIntervals / sampleRate(this);
end
