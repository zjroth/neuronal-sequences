%------------------------------------------------------------------------------
% USAGE:
%
%    [ripples, sharpWave, rippleWave] = DetectRipples(lfp, sampleRate, ...)
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
%------------------------------------------------------------------------------
function [ripples, sharpWave, rippleWave] = DetectRipples(lfp, varargin)
    % Optional parameter ideas:
    % - lfpEnvelope     (only use high/low if provided)
    % - outputFile      (a filename so in-progress work is not lost)
    % - rippleFreqRange (allowed frequencies for a ripple)
    % - duration        (how long can a ripple last)
    % - minSeparation   (how close can ripples be to each other)
    % - smoothingRadius (width of smoothing filter in milliseconds; single-sided?)
    % - thresholds?
    sampleRate = 2e4;
    smoothingRadius = 0.011; % Smooth over 2 maximum periods of the ripple frequency.
    rippleFreqRange = [90, 180];
    duration = [0.025, 0.200];
    minSeparation = 0.030;

    % threshold SD (standard deviation) for ripple detection
    minSharpWavePeak = 5;
    minRippleWavePeak = 4;

    % Parse the named parameter list in `varargin`.
    parseNamedParams();

    % Now that the optional parameter values have been set, we can use them to
    % deterine the values of certain variables to be used during the
    % computation.
    minDuration = round(duration(1) * sampleRate);
    maxDuration = round(duration(2) * sampleRate);
    minSeparation = round(minSeparation * sampleRate);
    minPeakSep = minDuration + minSeparation;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % detection

    % Create a Gaussian filter for smoothing signals.
    filter = gausswin(2 * smoothingRadius * sampleRate + 1);
    filter = filter / sum(filter);

    % Compute the "sharp-wave" signal that is depended on LFPs that polarize
    % during the ripple.
    sharpWave = computeSharpWave(lfp(:, 3), lfp(:, 1), filter);

    % Compute the "ripple-wave" signal that is determined by the LFP in which
    % the high-frequency ripple events are occuring.
    rippleWave = computeRippleWave(lfp(:, 2), rippleFreqRange, sampleRate, filter);

    % Now that we have the necessary signals, we can determine intervals in
    % which the peak of a ripple might be occuring by thresholding the signals
    % with the provided thresholds.
    aboveThr = (sharpWave > minSharpWavePeak) & (rippleWave > minRippleWavePeak);
    ripplePeakIntervals = getIntervals(aboveThr);

    % In addition to the intervals in which ripple peaks may occur, we also need
    % to determine (initial estimates for) intervals during which an entire
    % ripple may be occuring.
    rippleIntervals = getIntervals(sharpWave >= 1.5);

    % Now that we have the necessary intervals to consider, we want to classify
    % those events as ripples or not ripples. Initialize the necessary variables
    % here for storing the ripples and for keeping track of how many ripples we
    % have found.
    ripples = NaN(size(ripplePeakIntervals, 1), 3);
    numRipples = 0;

    % Loop through the collection of intervals in which the peaks live to build
    % the list of ripples.
    for i = 1 : size(ripplePeakIntervals, 1)
        % For convenience, store the current interval in which the peak exists.
        peakIntervalStart = ripplePeakIntervals(i, 1);
        peakIntervalEnd = ripplePeakIntervals(i, 2);

        % We assume for now that the current peak interval is part of a new
        % ripple, though we may determine otherwise later.
        numRipples = numRipples + 1;

        % Find the location of the peak of the current ripple, as determined by
        % the sharp-wave signal.
        [~, currRipplePeak] = max(sharpWave(peakIntervalStart : peakIntervalEnd));
        currRipplePeak = currRipplePeak + (peakIntervalStart - 1);

        % Initially, we set the ripple to be the entire width of the
        % above-determined ripple interval in which the ripple peak lies. Find
        % that interval, and set the corresponding start and end times.
        currRippleInterval = find(rippleIntervals(:, 1) < currRipplePeak, 1, 'last');
        currRippleStart = rippleIntervals(currRippleInterval, 1);
        currRippleEnd = rippleIntervals(currRippleInterval, 2);

        % Correct for the case that this ripple is too close to the previous
        % ripple.
        if i > 1
            % For convenience, store the pieces of the previous ripple.
            prevStart = ripples(numRipples - 1, 1);
            prevPeak = ripples(numRipples - 1, 2);
            prevEnd = ripples(numRipples - 1, 3);

            % If the peaks are too close, join them into a single ripple.
            if currRipplePeak - prevPeak < minPeakSep
                % Since we are joining ripples, there is one fewer ripple than
                % we previously thought.
                numRipples = numRipples - 1;

                % The peak of the merged ripple is the higher of the peaks of
                % the two ripples that are being joined.
                if rippleWave(currRipplePeak) < rippleWave(prevPeak);
                    currRipplePeak = prevPeak;
                end

                % Give the ripple the maximum duration (for now).
                currRippleStart = min(prevStart, currRippleStart);
                currRippleEnd = max(prevEnd, currRippleEnd);
            elseif currRippleStart - prevEnd < minSeparation
                % If the peaks are separated by enough distance and the ends of
                % the ripples are too close together, choose an appropriate
                % point between the peaks to split the ripples at.
                [~, splitPoint] = min(rippleWave(prevPeak : currRipplePeak));
                splitPoint = splitPoint + prevPeak - 1;

                % Ensure that the end of the previous ripple and the start of
                % the current ripple are separated by the minimum inter-ripple
                % period.
                prevEnd = splitPoint - ceil(minSeparation / 2);
                ripples(numRipples - 1, 3) = prevEnd;

                currRippleStart = splitPoint + ceil(minSeparation / 2);
            end
        end

        % Shorten this ripple if it is too long.
        [currRippleStart, currRipplePeak, currRippleEnd] = shortenRipple(...
            currRippleStart, currRipplePeak, currRippleEnd);

        % Finally, store the ripple in the matrix of ripple data.
        ripples(numRipples, :) = [currRippleStart, currRipplePeak, currRippleEnd];
    end

    % Ensure that the matrix of returned ripple data contains only the rows for
    % which we actually found a ripple.
    ripples = ripples(1 : numRipples, :);
end

function [newStart, newPeak, newEnd] = shortenRipple(...
    rippleStart, ripplePeak, rippleEnd)

    % Initialize the return variables.
    newStart = rippleStart;
    newPeak = ripplePeak;
    newEnd = rippleEnd;

    % Only do something if the ripple is too long.
    if (newEnd - newStart > maxDuration)
        % At least one end point of the ripple has to be more than
        % half of the maximum allowed period.
        headLength = newPeak - newStart;
        tailLength = newEnd - newPeak;

        % Variables to store whether the head and tail of the ripple (i.e., the
        % parts before and after the peak) are too long.
        headTooLong = (headLength > maxDuration / 2);
        tailTooLong = (tailLength > maxDuration / 2);

        % Now simply shorten the appropriate parts of the ripple.
        if headTooLong && tailTooLong
            newStart = newPeak - maxDuration / 2;
            newEnd = newPeak + maxDuration / 2;
        elseif headTooLong
            newStart = newPeak - (maxDuration - tailLength);
        elseif tailTooLong
            newEnd = newPeak + (maxDuration - headLength);
        end
    end
end
