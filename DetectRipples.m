% USAGE:
%
%    [ripples, sharpWave, rippleWave] = DetectRipples(lfp, ...)
%
% DESCRIPTION:
%
%    Detect ripples...
%
% ARGUMENTS:
%
%    lfp
%       The LFP data to work with
%    sampleRate
%       The sample rate of the data set
%
% RETURNS:
%
%    ripples
%       Matrix with rows of the form [startTime, peakTime, endTime]
%    fShp
%       .
%    fRip
%       .
%
% NOTES:
%
%    This function needs to be cleaned up quite a bit (and perhaps be
%    completely rewritten). In particular, the arguments `samplRate` and
%    `totNch` can be read in from a metadata file. Also, a large number of
%    parameters are set at the beginning of the file; these parameters should
%    be capable of being set with an optional arguments to the function call.
function [ripples, sharpWave, rippleWave] = DetectRipples( ...
    sharpWave, rippleWave, varargin)
    %=======================================================================
    % Default optional parameter values
    %=======================================================================

    % Optional parameter ideas:
    % - outputFile      (a filename so in-progress work is not lost)
    % - rippleFreqRange (allowed frequencies for a ripple)
    % - duration        (how long can a ripple last)
    % - minSeparation   (how close can ripples be to each other)
    % - smoothingRadius (width of smoothing filter in milliseconds; single-sided?)
    % - thresholds?
    sampleRate = 2e4;
    duration = [0.025, 0.200];
    minSeparation = 0.030;

    % threshold SD (standard deviation) for ripple detection
    minSharpWavePeak = 4;
    minSharpWave = 1.5;
    minRippleWavePeak = 2;
    minRippleWave = 1;

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
    secondDerivative = [0; diff(firstDerivative)] * sampleRate;

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
    % those events as ripples or not ripples. Initialize the necessary variables
    % here for storing the ripples and for keeping track of how many ripples we
    % have found.
    ripples = NaN(size(rippleIntervals, 1), 3);
    numRipples = 0;

    % Loop through the collection of "ripple intervals" to build the list of
    % ripples. We proceed by saying that one ripple exists for each "ripple
    % interval" in which a "peak interval" is contained.
    for i = 1 : size(rippleIntervals, 1)
        % The start and end of the ripple.
        intervalStart = rippleIntervals(i, 1);
        intervalEnd = rippleIntervals(i, 2);

        % Before considering the current interval to be a ripple, it must
        % pass some tests: it must contain a peak interval, and it must
        % contain a...*cough*...sharp change in the sharp-wave.
        containsPeak = any( ...
            (ripplePeakIntervals(:, 1) >= intervalStart) & ...
            (ripplePeakIntervals(:, 2) <= intervalEnd));

        containsSharpChange = any(...
            (highDerivatives >= intervalStart) & ...
            (highDerivatives <= intervalEnd));

        if containsPeak && containsSharpChange
            % A new ripple has been found.
            numRipples = numRipples + 1;

            % Now, the current interval designates the start and end of the
            % newly-found ripple. Also find the location of the peak of the
            % newly-found ripple, as determined by the sharp-wave signal.
            ripplePeak = getPeak(sharpWave, intervalStart, intervalEnd);

            ripples(numRipples, :) = [intervalStart, ripplePeak, intervalEnd];
        end
    end

    % Keep only those rows that we've actually classified as ripples.
    ripples = ripples(1 : numRipples, :);

    % Split the ripples.
    peaks = findpeaks(secondDerivative);
    splitPoints = peaks.loc;
    splitPointVals = secondDerivative(splitPoints);
    splitPoints = splitPoints(splitPointVals > minSecondDerivative);
    ripples = splitRipples(ripples, sharpWave, splitPoints);

    % Shorten any ripples that are too long.
    ripples = shortenRipples(ripples, maxDuration);

%    % Correct adjacent ripples (that are too close).
%    ripples = correctAdjacent(ripples, minSeparation);
%
    % Finally, convert the ripples from index data to time data.
    ripples = ripples / sampleRate;
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
        for i = 1 : length(starts)
            numRipples = numRipples + 1;

            ripplesOut(numRipples, 1) = starts(i);
            ripplesOut(numRipples, 2) = getPeak( ...
                sharpWave, starts(i), ends(i));
            ripplesOut(numRipples, 3) = ends(i);
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
    peak = peak + (startIndex - 1);
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
