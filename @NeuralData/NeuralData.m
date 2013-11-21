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
        Clu = []
        Laps = []
        Spike = []
        Track = []
        xml = []

        smoothingRadius = 0.03;
        ripples

        rawSampleTimes
    end

    properties (GetAccess = public, SetAccess = public)
        data = []
        saved = []
        parameters = []
    end

    properties (GetAccess = protected, SetAccess = protected)
        strBehavElectrDataLFP

        baseFolder
        baseFileName
        cachePath

        currentChannels = []
        currentLfps = []

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
        %    Initialize a `NeuralData` object by loading from a specified
        %    data folder.
        %
        % ARGUMENTS:
        %
        %    strPath
        %
        %       The path to the folder in which the data resides
        %
        %---------------------------------------------------------------
        function this = NeuralData(strDataPath, strCachePath)
            % Find the name of the recording.
            cellFiles = findFiles(strDataPath, '^A\d{1,4}-\d{8}-\d{2}\.dat$');

            assert(length(cellFiles) > 0, ...
                   ['Please ensure that the data file matches the following ' ...
                    'regular expression and that all other files start with ' ...
                    'the same name (sans extension): ' ...
                    '''^A\d{1,4}-\d{8}-\d{2}\.dat$''']);

            assert(logical(exist(strCachePath, 'dir')), ...
                   'Please ensure that the cache is a valid directory');

            % We've found our data file. Extract the base file name from it.
            strBaseFileName = cellFiles{1};
            strBaseFileName = strBaseFileName(1 : end - 4);

            % Store the folder and base filename in this object.
            this.baseFolder = strDataPath;
            this.baseFileName = strBaseFileName;
            this.cachePath = strCachePath;

            % Load and store information about the data in this recording.
            this.strBehavElectrDataLFP = ...
                fullfile(strDataPath, ...
                         [strBaseFileName '_BehavElectrDataLFP.mat']);
        end
    end

    % getters and setters
    methods (Access = public)
        function uknOut = getClu(this, strField)
            if isempty(this.Clu)
                stctContents = load(this.strBehavElectrDataLFP, 'Clu');
                this.Clu = stctContents.Clu;
            end

            if nargin == 2
                uknOut = this.Clu.(strField);
            else
                uknOut = this.Clu;
            end
        end

        function uknOut = getLaps(this, strField)
            if isempty(this.Laps)
                stctContents = load(this.strBehavElectrDataLFP, 'Laps');
                this.Laps = stctContents.Laps;
            end

            if nargin == 2
                uknOut = this.Laps.(strField);
            else
                uknOut = this.Laps;
            end
        end

        function uknOut = getSpike(this, strField)
            if isempty(this.Spike)
                stctContents = load(this.strBehavElectrDataLFP, 'Spike');
                this.Spike = stctContents.Spike;
            end

            if nargin == 2
                uknOut = this.Spike.(strField);
            else
                uknOut = this.Spike;
            end
        end

        function uknOut = getTrack(this, strField)
            if isempty(this.Track)
                stctContents = load(this.strBehavElectrDataLFP, 'Track');
                this.Track = stctContents.Track;
            end

            if nargin == 2
                uknOut = this.Track.(strField);
            else
                uknOut = this.Track;
            end
        end

        function uknOut = getXml(this, strField)
            if isempty(this.xml)
                stctContents = load(this.strBehavElectrDataLFP, 'xml');
                this.xml = stctContents.xml;
            end

            if nargin == 2
                uknOut = this.xml.(strField);
            else
                uknOut = this.xml;
            end
        end

        function clearBehavElectrDataLFP(this)
            this.Clu = [];
            this.Laps = [];
            this.Spike = [];
            this.Track = [];
            this.xml = [];
        end

        function clearLfpData(this)
            this.currentLfps = [];
        end
    end

    % Other methods
    methods (Access = public)
        cellSpikeTimes = groupSpikes(this)

        loadChannels(this, nMain, nLow, nHigh)

        objLfps = getLfps(this)
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
        hndl = plotRipple(this, nRipple, varargin)
        plotRippleSpikeTrains(this, nRipple, varargin)

        [ripples, stctIntermediate] = detectRipples(this, sharpWave, rippleWave, timeData, varargin)

        rate = rawSampleRate(this)
        rate = sampleRate(this)

        vOrdering = sortNeuronsInWindow(this, vTimeWindow, varargin)
        vOrdering = sortNeuronsForRipple(this, nRipple, varargin)

        ripples = getRipples(this, rippleNums)
        setRipple(this, rippleNum, vStartPeakEnd)
        trains = getSpikeTrains(this, bRemoveInterneurons)
        plotLfps(this, varargin)
        vNearest = getNearestRipples(this, nRipple)

        activeNeurons = getRippleActivity(this, nRipple)
        nRipples = getRippleCount(this)
        removeRipple(this, nRipple)
        vSequence = getSequence(this, vTimeWindow, varargin)
        cellSequences = getSequences(this, mtxTimeWindows, bRemoveInterneurons)
        vSequence = getRippleSequence(this, nRipple, bRemoveInterneurons)
        cellSequences = getRippleSequences(this, varargin)
        cellSequences = getPlaceFieldSequences(this, varargin)
        cellSequences = getWheelSequences(this, varargin)

        mtxTimeWindows = getWheelIntervals(this)
        mtxTimeWindows = getPlaceFieldIntervals(this)
        [mtxEvents, nRipples, nWheelEvents, nPlaceFieldEvents] = getEvents(this)

        modifyRipple(this, nRipple, nStartTime, nEndTime)
        modifyRipples(this, varargin)

        detectInterneurons(this)
        vInterneurons = getInterneurons(this)

        dDuration = getRecordingDuration(this)
        mtxLocations = getSpikeLocations(this)
        vPoint = getLocationsAtTime(this, dTime, strUnits)
        vSpeeds = getSpeedsAtTimes(this, vTimes, dWindowWidth, strUnits)
    end
end
