% cellSequences = getThetaSequences(this, varargin)
function [cellSequences, cellClassification] = getThetaSequences(this, varargin)
    [mtxTimeWindows, cellClassification] = getThetaIntervals(this);
    cellSequences = getSequences(this, mtxTimeWindows, varargin{:});
end
