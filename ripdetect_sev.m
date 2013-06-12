%------------------------------------------------------------------------------
% Usage:
%    [spw, fShp, fRip] = ripdetect_sev(dat, sampleRate, outputFile)
% Description:
%    Detect ripples in a given SEV file.
% Arguments:
%    filename
%       The filename of the data file to read.
%    sampleRate
%       The sample rate of the data set.
%    outputFile
%       If this output filename is provided, the results of this simulation
%       are written to this file.
% Returns:
%    spw
%       .
%    dat
%       .
%    fShp
%       .
%    fRip
%       .
% Notes:
%    This function needs to be cleaned up quite a bit (and perhaps be
%    completely rewritten). In particular, the arguments `samplRate` and
%    `totNch` can be read in from a metadata file. Also, a large number of
%    parameters are set at the beginning of the file; these parameters should
%    be capable of being set with an optional arguments to the function call.
%------------------------------------------------------------------------------
function [spw, fShp, fRip] = ripdetect_sev(dat, sampleRate, outputFile)
    %%%%%%%%%% parameters to play with %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % parameters for program flow control
    plotFig = false;

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

    dat = downsample(dat, downsampleRat);

    % Create a Gaussian filter for smoothing signals.
    filtLength = 100;
    sigma = 75;
    filter=1/sqrt(2*pi*sigma^2)*exp(-[0:filtLength-1].^2/(2*sigma^2));
    filter=[filter(end:-1:2) filter];

    % detect sharp waves based on SD-based threshold:
    fShp = computeSharpWave(dat(:, 3), dat(:, 1), filter);

    % detect ripple power
    fRip = computeRipplePower(dat(:, 2), [lowband, highband], sampleRate, filter);

    % get events with large sharpwave/ripple content
    aboveThr = (fShp > shpThresh_multipSD) & (fRip > ripThresh_multipSD);
    [evUp evDown] = SchmittTrigger_e(aboveThr, 0.5, 0.5);

    % get features for each ripple/shpw event
    nRip = 0;

    spw=[];
    spw.endT = 0;
    figOffset = round(sampleRate/4);
    detOffset = round(sampleRate/6);

    disp('Detecting ripples.....');
    for nEvnt = 1 : length(evUp)-1
        t1 = evUp(nEvnt);
        t2 = t1 + max_sw_period;
        if (t1-spw.endT) > min_isw_period
            nRip = nRip + 1;
            [ripAmpl ripInd] = max(fShp(max(1,t1-detOffset):min(t2+detOffset,length(fShp))));
            spw.peakT(nRip) = max(1,t1-detOffset)+ripInd;

            % ZACH: I don't have this file.
            c = SchmittTriggerUpDownMarked(fShp(1:spw.peakT(nRip)),1.5,1.5);
            spw.startT(nRip) = c(end);
            [cU cD] = SchmittTriggerUpDownMarked(fShp(spw.peakT(nRip):end),1.5,1.5);
            spw.endT(nRip) = cD(1) + spw.peakT(nRip);
            spw.shpwPeakAmplSD(nRip) = ripAmpl;
            spw.ripPeakAmplSD(nRip) = max(fRip(spw.startT(nRip):spw.endT(nRip)));

            % if starting at least min_isw_period after the previous ripple event
            if plotFig
                range = (t1 - figOffset : t2 + figOffset);
                timeData = range / (sampleRate / 1000);
                event = [spw.startT(nRip), spw.peakT(nRip), spw.endT(nRip)];
                event = (event - range(1)) / (sampleRate / 1000);
                plotRipple(timeData, dat(range, :), fShp(range), fRip(range), event);
            end
        end
    end

    % Save the output of this trial in the given location.
    if nargin == 5 && ~isempty(outputFile)
        save(outputFile, 'spw');
        MakeEvtFile_e([spw.startT; spw.peakT; spw.endT]', ...
                      outputFile,                         ...
                      {'ripStart', 'ripPeak', 'ripDown'}, ...
                      sampleRate, 1);
    end
end
