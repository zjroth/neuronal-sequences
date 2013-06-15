%------------------------------------------------------------------------------
% USAGE:
%
%    [spw, dat, fShp, fRip] = DetectRipples(lfp, sampleRate, ...)
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
%    spw
%       .
%    dat
%       .
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
function [spw, fShp, fRip] = DetectRipples(lfp, sampleRate, varargin)

    % Parameter ideas:
    % - lfpEnvelope (only use high/low if provided)
    % - output (a filename so in-progress work is not lost)
    % - freqRange (allowed frequencies for a ripple)
    % - durationRange (how long can a ripple be)
    % - minSeparation (how close can ripples be to each other)
    % - filterWidth (width of smoothing filter in milliseconds; single-sided?)
    % - thresholds?
    % Parameters to exclude:
    % - downsampleRate (just do this before calling the function)
    %
    filterWidth = 10;

    highband = 200; % bandpass filter range (180Hz to 90Hz)
    lowband = 90; %
    downsampleRat = 1;
    sampleRate = sampleRate/downsampleRat;

    % These have been moved to `computeRipplePower` for now.
    %   filtOrder = 500;  % filter order has to be even; .. the longer the more
    %                     % selective, but the operation will be linearly slower
    %                     % to the filter order
    %   filtOrder = ceil(filtOrder/2)*2;           %make sure filter order is even
    %   avgFiltOrder = 501; % do not change this... length of averaging filter

    % This was not being used in Eva's original code.
    %   avgFiltDelay = floor(avgFiltOrder/2);  % compensated delay period

    % parameters for ripple period (ms)
    min_sw_period = round(0.025*sampleRate/downsampleRat) ; % minimum sharpwave period = 50ms ~ 6 cycles
    max_sw_period = round(0.250*sampleRate/downsampleRat); % maximum sharpwave period = 250ms ~ 30 cycles
                                                           % of ripples (max, not used now)
    min_isw_period = round(0.030*sampleRate/downsampleRat); % minimum inter-sharpwave period;

    % threshold SD (standard deviation) for ripple detection
    shpThresh_multipSD = 5;     % threshold for ripple detection
    ripThresh_multipSD = 4; % the peak of the detected region must satisfy
                            % this value on top of being supra-thresholdf.

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % detection
    lfp = downsample(lfp, downsampleRat);

    % Create a Gaussian filter for smoothing signals.
    filter = gausswin(filterWidth * sampleRate);
    filter = filter / sum(filter);

    % detect sharp waves based on SD-based threshold:
    fShp = computeSharpWave(lfp(:, 3), lfp(:, 1), filter);

    % detect ripple power
    fRip = computeRipplePower(lfp(:, 2), [lowband, highband], sampleRate, filter);

    % get events with large sharpwave/ripple content
    aboveThr = (fShp > shpThresh_multipSD) & (fRip > ripThresh_multipSD);
    [aboveStdevCrossing, ~] = SchmittTriggerUpDownMarked(aboveThr, 0.5, 0.5);

    [upCrossings, downCrossings] = SchmittTriggerUpDownMarked(fShp, 1.5, 1.5);

    % get features for each ripple/shpw event
    nRip = 0;

    spw=[];
    spw.endT = 0;
    detOffset = round(sampleRate/6);

    disp('Detecting ripples.....');
    for crossingIndex = aboveStdevCrossing
        t2 = crossingIndex + max_sw_period;

        % A crossing time only indicates the start of a ripple if enough time has
        % elapsed since the previous ripple.
        if (crossingIndex - spw.endT) > min_isw_period
            nRip = nRip + 1;

            % Find the maximum of the sharp-wave signal between the crossing
            % index and the last possible index (based on the maximum width
            % of the ripple). This maximum value is the sharp-wave's peak
            % amplitude, and the index of this maximum is the index of the
            % peak of this ripple.
            [ripAmpl ripInd] = max(fShp(crossingIndex : t2));
            spw.shpwPeakAmplSD(nRip) = ripAmpl;
            spw.peakT(nRip) = ripInd;

            % Find the last place between the start of the sharp-wave signal
            % and the peak of this ripple that the signal goes above 1.5.
            % This is the start of the ripple.
            % Why 1.5?
            spw.startT(nRip) = find(upCrossings < spw.peakT(nRip), 1, 'last');

            % Find the first down crossing between the peak of the ripple and
            % the end of the signal. This is the end of this ripple.
            spw.endT(nRip) = find(downCrossings > spw.peakT(nRip), 1, 'first');

            % Find the ripple's peak amplitude.
            spw.ripPeakAmplSD(nRip) = max(fRip(spw.startT(nRip) : spw.endT(nRip)));
        end
    end
end
