%
% DESCRIPTION:
%
%    Provide convenient access to neural data and methods related to ripple
%    detection.
%
% PROPERTIES:
%
%    .
%
% METHODS:
%
%    .
%
% STATIC METHODS:
%
%    .
%
classdef NeuralData < handle
    properties (GetAccess = public, SetAccess = protected)
        Clu
        Laps
        Spike
        Track
        xml

        smoothingRadius = 0.03;
        ripples

        rawSampleTimes
    end

    properties (GetAccess = public, SetAccess = public)
        parameters = []
    end

    properties (GetAccess = protected, SetAccess = protected)
        baseFolder
        baseFileName

        currentChannels
        currentLfps

        current = []
    end

    methods (Access = public)
        %---------------------------------------------------------------
        %
        % USAGE:
        %
        %    obj = NeuralData()
        %
        % DESCRIPTION:
        %
        %    .
        %
        % ARGUMENTS:
        %
        %    .
        %       .
        %
        %---------------------------------------------------------------
        function this = NeuralData(filename)
            [baseFolder, baseFileName, ~] = fileparts(filename);

            this.baseFolder = baseFolder;
            this.baseFileName = baseFileName;

            load(fullfile(baseFolder, [baseFileName '_BehavElectrDataLFP.mat']));

            this.Clu = Clu;
            this.Laps = Laps;
            this.Spike = Spike;
            this.Track = Track;
            this.xml = xml;
        end
    end

    methods (Access = public)
        clusterSpikeTimes = groupSpikes(this)

        loadChannels(this, main, low, high)

        [lfp, ch] = mainLfp(this, indices)
        [lfp, ch] = lowLfp(this, indices)
        [lfp, ch] = highLfp(this, indices)

        sharpWave = getSharpWave(this, bDownsample);
        computeSharpWave(this);
        objRippleWave = getRippleWave(this, varargin);

        [spect, spectTimes, spectFrequencies] = getRippleSpectrogram(this, varargin);

        n = numDataChannels(this)

        %plt = plotRipples(this, ...)
        fig = plotRipplesVsSpikes(this, varargin)

        ripples = detectRipples(this, sharpWave, rippleWave, timeData, varargin)

        rate = rawSampleRate(this)
        rate = sampleRate(this)

        ordering = sortNeuronsForRipple(this, rippleNumber, varargin)
        ripples = getRipples(this, rippleNums)
        setRipple(this, rippleNum, vStartPeakEnd)
        trains = getSpikeTrains(this)
        plotLfps(this, varargin)
        vNearest = getNearestRipples(this, nRipple)
        computeRippleSpikeMatrix(this)
        rippleSpikeMatrix = getRippleSpikeMatrix(this)

        activeNeurons = getRippleActivity(this, nRipple)
        nRipples = getRippleCount(this)
        removeRipple(this, nRipple)

        % Method ideas:
        %    mtx = ripples(this, channels)
        %       This is fast to compute. Don't provide functionality for
        %       saving unless we have a specific reason to. I'm thinking that
        %       this should just be the "DetectRipples" function; move it in
        %       here.
        %
        %    lfpTs = lfp(this, channels)
        %        These are surprisingly slow to extract from the .dat file.
        %        Should I provide functionality for saving? Probably not. I'm
        %        thinking of using the FMAToolbox function "LoadBinary".
        %
        % Other ideas:
        %    If we do need to store ripples for some reason, use files of the
        %    form `ch-<low>-<main>-<high>.rpl` in the subfolder "computed".
    end
end