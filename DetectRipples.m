%
% USAGE:
%
%    ripples = DetectRipples(sharpWave, rippleWave, ...)
%
% DESCRIPTION:
%
%    Detect sharp-wave ripples.
%
% ARGUMENTS:
%
%    sharpWave
%       .
%
%    rippleWave
%       .
%
% OPTIONAL PARAMETERS:
%
%    sampleRate (default: 2e4)
%       .
%
%    duration (default: [0.025, 0.200])
%       .
%
%    minSeparation (default: 0.030)
%       .
%
%    minSharpWavePeak (default: 4)
%       .
%
%    minSharpWave (default: 1.5)
%       .
%
%    minRippleWavePeak (default: 2)
%       .
%
%    minRippleWave (default: 1)
%       .
%
%    minFirstDerivative (default: 3)
%       .
%
%    minSecondDerivative (default: 3)
%       .
%
% RETURNS:
%
%    ripples
%
%       Matrix with entries in seconds and rows of the form [start, peak, end]
%
function ripples = DetectRipples(sharpWave, rippleWave, varargin)
    %=======================================================================
    % Default optional parameter values
    %=======================================================================

    sampleRate = 2e4;
    duration = [0.025, 0.200];
    minSeparation = 0.030;

    minSharpWavePeak = 2;
    minSharpWave = 1.6;

    minRippleWavePeak = 0;
    minRippleWave = -Inf;

    minFirstDerivative = 2.75;
    minSecondDerivative = 2.9;

    %=======================================================================
    % Initialization and value-checking
    %=======================================================================

    % Ensure that the signals are column vectors of the same length.
    assert(iscolumn(sharpWave) && iscolumn(rippleWave));
    assert(length(sharpWave) == length(rippleWave));

    % Parse the named parameter list in `varargin`.
    parseNamedParams();

    % Now that the optional parameter values have been set, we can use them to
    % deterine the values of certain variables to be used during the
    % computation.
    minDuration = ceil(duration(1) * sampleRate);
    maxDuration = floor(duration(2) * sampleRate);
    minSeparation = ceil(minSeparation * sampleRate);
    minPeakSep = minDuration + minSeparation;

    %=======================================================================
    % Actual computations
    %=======================================================================

    % Find the first and second derivatives of the sharp-wave.
    firstDerivative = [0; diff(sharpWave)] * sampleRate;
    firstDerivative = firstDerivative / std(firstDerivative);

    secondDerivative = [0; diff(firstDerivative)] * sampleRate;
    secondDerivative = secondDerivative / std(secondDerivative);

    % Now that we have the necessary signals, we can determine intervals in
    % which the peak of a ripple might be occuring by thresholding the signals
    % with the provided thresholds.
    ripplePeakIntervals = getIntervals(  ...
        (sharpWave > minSharpWavePeak) & ...
        (rippleWave > minRippleWavePeak));

    % In addition to the intervals in which ripple peaks may occur, we also need
    % to determine (initial estimates for) intervals during which an entire
    % ripple may be occuring.
    rippleIntervals = getIntervals(   ...
        (sharpWave >= minSharpWave) & ...
        (rippleWave >= minRippleWave));

    % Fill in the gaps. We will split ripples that are too long later.
    %rippleIntervals = fillGaps(rippleIntervals, minSeparation / 2);

    % Only consider those intervals that are long enough.
    rippleIntervals = rippleIntervals( ...
        rippleIntervals(:, 2) - rippleIntervals(:, 1) >= minDuration, :);

    % In addition to requiring the sharp-wave to be above a certain
    % threshold, we will also require that it increases sharply during the
    % course of the ripple, thus forming the "envelope" or "packet" that
    % characterizes the look of these events.
    highDerivatives = find(firstDerivative > minFirstDerivative);

    % Now that we have the necessary intervals to consider, we want to classify
    % those events as ripples or not ripples. Initially, we say that each ripple
    % interval contains a ripple. Store each ripple as a triple, specifically in
    % the form [start, peak, end].
    ripplePeaks = arrayfun(@(s, e) getPeak(sharpWave, s, e), ...
        rippleIntervals(:, 1), rippleIntervals(:, 2));
    ripples = [rippleIntervals(:, 1), ripplePeaks, rippleIntervals(:, 2)];

    % Split the ripples.
    secondDerivativePeaks = findpeaks(secondDerivative);
    splitPoints = secondDerivativePeaks.loc;
    splitPointVals = secondDerivative(splitPoints);
    splitPoints = splitPoints(splitPointVals > minSecondDerivative);
    ripples = splitRipples(ripples, sharpWave, splitPoints);

    % Keep only those ripples that have high enough peaks in the sharp-wave
    % signal and in its first derivative.
    ripples = ripplesWithPeaks(ripples, ripplePeakIntervals);
    ripples = ripplesWithSharpChange(ripples, highDerivatives);

    % Shorten any ripples that are too long.
    ripples = shortenRipples(ripples, maxDuration);

%    % Correct adjacent ripples (that are too close).
%    ripples = correctAdjacent(ripples, minSeparation);

    % Remove ripples that are too short.
    ripples = ripples(ripples(:, 3) - ripples(:, 1) >= minDuration, :);

    % Finally, convert the ripples from index data to time data.
    ripples = ripples / sampleRate;
end

function ripplesOut = ripplesWithPeaks(ripplesIn, peakIntervals)
    containsPeak = false(size(ripplesIn, 1), 1);

    for i = 1 : size(ripplesIn, 1)
        rippleStart = ripplesIn(i, 1);
        rippleEnd = ripplesIn(i, 3);

        containsPeak(i) = any( ...
            (peakIntervals(:, 1) >= rippleStart) & ...
            (peakIntervals(:, 2) <= rippleEnd));
    end

    ripplesOut = ripplesIn(containsPeak, :);
end

function ripplesOut = ripplesWithSharpChange(ripplesIn, highDerivatives)
    containsSharpChange = false(size(ripplesIn, 1), 1);

    for i = 1 : size(ripplesIn, 1)
        rippleStart = ripplesIn(i, 1);
        rippleEnd = ripplesIn(i, 3);

        containsSharpChange(i) = any(...
            (highDerivatives >= rippleStart) & ...
            (highDerivatives <= rippleEnd));
    end

    ripplesOut = ripplesIn(containsSharpChange, :);
end

function ripplesOut = splitRipples(ripplesIn, sharpWave, splitPoints)
    ripplesOut = NaN(size(ripplesIn));
    numRipples = 0;

    % Split the ripples.
    for i = 1 : size(ripplesIn, 1)
        % The start and end of the current ripple.
        rippleStart = ripplesIn(i, 1);
        rippleEnd = ripplesIn(i, 3);

        % The split points that are local to the current ripple.
        localSplitPoints = splitPoints( ...
            splitPoints > rippleStart & ...
            splitPoints < rippleEnd);

        % The lists of starting and ending points of the found subripples.
        starts = [rippleStart; localSplitPoints];
        ends   = [localSplitPoints; rippleEnd];

        % Append to the output each newly-found subripple.
        for j = 1 : length(starts)
            numRipples = numRipples + 1;

            ripplesOut(numRipples, 1) = starts(j);
            ripplesOut(numRipples, 2) = getPeak( ...
                sharpWave, starts(j), ends(j));
            ripplesOut(numRipples, 3) = ends(j);
        end
    end
end

function ripplesOut = shortenRipples(ripplesIn, maxDuration)
    ripplesOut = ripplesIn;

    for i = 1 : size(ripplesOut, 1)
        % Initialize the return variables.
        rippleStart = ripplesOut(i, 1);
        ripplePeak  = ripplesOut(i, 2);
        rippleEnd   = ripplesOut(i, 3);

        % Only do something if the ripple is too long.
        if (rippleEnd - rippleStart > maxDuration)
            % At least one end point of the ripple has to be more than
            % half of the maximum allowed period.
            headLength = ripplePeak - rippleStart;
            tailLength = rippleEnd - ripplePeak;

            % Variables to store whether the head and tail of the ripple
            % (i.e., the parts before and after the peak) are too long.
            headTooLong = (headLength > maxDuration / 2);
            tailTooLong = (tailLength > maxDuration / 2);

            % Now simply shorten the appropriate parts of the ripple.
            if headTooLong && tailTooLong
                rippleStart = ripplePeak - maxDuration / 2;
                rippleEnd = ripplePeak + maxDuration / 2;
            elseif headTooLong
                rippleStart = ripplePeak - (maxDuration - tailLength);
            elseif tailTooLong
                rippleEnd = ripplePeak + (maxDuration - headLength);
            end

            % Save the shortened ripple.
            ripplesOut(i, [1, 3]) = [rippleStart, rippleEnd];
        end
    end
end

function ripplesOut = correctAdjacent(ripplesIn, minSep)
    ripplesOut = ripplesIn;

%     % Correct for the case that this ripple is too close to the previous
%     % ripple.
%     if i > 1
%         % For convenience, store the pieces of the previous ripple.
%         prevStart = ripples(numRipples - 1, 1);
%         prevPeak = ripples(numRipples - 1, 2);
%         prevEnd = ripples(numRipples - 1, 3);
%
%         % If the peaks are too close, join them into a single ripple.
%         if currRipplePeak - prevPeak < minPeakSep
%             % Since we are joining ripples, there is one fewer ripple than
%             % we previously thought.
%             numRipples = numRipples - 1;
%
%             % The peak of the merged ripple is the higher of the peaks of
%             % the two ripples that are being joined.
%             if sharpWave(currRipplePeak) < sharpWave(prevPeak);
%                 currRipplePeak = prevPeak;
%             end
%
%             % Give the ripple the maximum duration (for now).
%             currRippleStart = min(prevStart, currRippleStart);
%             currRippleEnd = max(prevEnd, currRippleEnd);
%         elseif currRippleStart - prevEnd < minSeparation
%             % If the peaks are separated by enough distance and the ends of
%             % the ripples are too close together, choose an appropriate
%             % point between the peaks to split the ripples at.
%             [~, splitPoint] = min(sharpWave(prevPeak : currRipplePeak));
%             splitPoint = splitPoint + prevPeak - 1;
%
%             % Ensure that the end of the previous ripple and the start of
%             % the current ripple are separated by the minimum inter-ripple
%             % period.
%             prevEnd = splitPoint - ceil(minSeparation / 2);
%             ripples(numRipples - 1, 3) = prevEnd;
%
%             currRippleStart = splitPoint + ceil(minSeparation / 2);
%         end
%     end
end

function peak = getPeak(data, startIndex, endIndex)
    [~, peak] = max(data(startIndex : endIndex));
    peak = startIndex + (peak - 1);
end

function varargout = synctimes(varargin)
    idx = NaN;
    shortest = Inf;

    % Find the shortest timeseries
    for i = 1 : nargin
        if length(varargin{i}.Time) < shortest
            idx = i;
            shortest = length(varargin{i}.Time);
        end
    end

    times = varargin{idx}.Time;

    % Resample where necessary.
    for i = 1 : nargin
        if i ~= idx
%            assert(all(ismember(times, varargin{i}.Time)));

            % Because of the above assertion, we only need to resample if the
            % current timeseries is longer than the shortest.
            if shortest < length(varargin{i}.Time)
                varargout{i} = resample(varargin{i}, times);
            else
                varargout{i} = varargin{i};
            end
        end
    end

    varargout{idx} = varargin{idx};
end
