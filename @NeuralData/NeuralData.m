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

        smoothingRadius = 0.005;
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
        % USAGE:
        %    obj = NeuralData()
        %
        % DESCRIPTION:
        %    Initialize a `NeuralData` object by loading from a specified
        %    data folder.
        %
        % ARGUMENTS:
        %    uknDataPath
        %       If a cell array:
        %       - its first element is the directory containing the data
        %       - its second element is the base recording name; there must be
        %         a file named [uknDataPath '.dat'] in the data directory.
        %       If a string, it is the directory containing the data; and the
        %       base recording name is inferred from directory path.
        %    strPath
        %       The path to the folder in which the data resides
        %---------------------------------------------------------------
        function this = NeuralData(uknDataPath, strCachePath)
            % Find the location of the .dat file for this recording.
            if iscell(uknDataPath)
                % Things are easy: A recording name was explicitly specified.
                strDataDir = uknDataPath{1};
                strDatFile = [uknDataPath{2} '.dat'];
            elseif ischar(uknDataPath)
                % A recording name wasn't specified explicitly, so we need to
                % work a little harder.
                strDataDir = uknDataPath;

                % Find all .dat files in the specified directory.
                cellDatFiles = findfiles(strDataDir, '\.dat$');

                if length(cellDatFiles) == 1
                    strDatFile = cellDatFiles{1};
                elseif length(cellDatFiles) > 1
                    strPrefix = commonprefix(cellDatFiles);
                    [nMinLength, nIndex] = min(cellfun(@length, cellDatFiles));

                    if length(strPrefix) == (nMinLength - 4)
                        strDatFile = cellDatFiles{nIndex};
                    end
                end
            else
                error('NeuralData: unrecognized first input parameter');
            end

            % Ensure that we can find the data file in the data directory.
            bFileExists = (exist('strDatFile', 'var') && ...
                           exist(fullfile(strDataDir, strDatFile), 'file'));
            assert(bFileExists, ...
                   ['NeuralData: incorrect base recording name; ']);, ...
                   ['see `help NeuralData` for more information']);

            % If the file above exists, we know what the recording name is.
            strRecording = strDatFile(1 : end - 4);

            % Make sure that the cache exists.
            assert(logical(exist(strCachePath, 'dir')), ...
                   'Please ensure that the cache is a valid directory');

            % Store the folder and recording name in this object.
            this.baseFolder = strDataDir;
            this.baseFileName = strRecording;
            this.cachePath = fullfile(strCachePath, strRecording);

            if ~exist(this.cachePath, 'dir')
                mkdir(this.cachePath);
            end

            % Load and store information about the data in this recording.
            this.strBehavElectrDataLFP = ...
                fullfile(strDataDir, ...
                         [strRecording '_BehavElectrDataLFP.mat']);
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

        nNeurons = getNeuronCount(this)
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
        [vSequence, vTimes] = getSequence(this, vTimeWindow, varargin)
        [cellSequences, cellTimes] = getSequences(this, mtxTimeWindows, bRemoveInterneurons)
        vSequence = getRippleSequence(this, nRipple, bRemoveInterneurons)
        cellSequences = getRippleSequences(this, varargin)
        cellSequences = getPlaceFieldSequences(this, varargin)
        cellSequences = getWheelSequences(this, varargin)
        [cellSequences, cellClassification] = getThetaSequences(this, varargin)

        [mtxTimeWindows, cellClassification] = getThetaIntervals(this)
        mtxTimeWindows = getWheelIntervals(this)
        [mtxTimeWindows, cellClassification] = getPlaceFieldIntervals(this)

        objEvent = getEvent(this, vTimeWindow, strClassification)
        cellEvents = getEvents(this, mtxTimeWindows, uknClassification)
        cellEvents = getPlaceFieldEvents(this);
        cellEvents = getThetaEvents(this);
        cellEvents = getWheelEvents(this);

        modifyRipple(this, nRipple, nStartTime, nEndTime)
        modifyRipples(this, varargin)

        detectInterneurons(this)
        vInterneurons = getInterneurons(this)

        dDuration = getRecordingDuration(this)
        mtxLocations = getSpikeLocations(this)
        vPoint = getLocationsAtTime(this, dTime, strUnits)
        vSpeeds = getSpeedsAtTimes(this, vTimes, dWindowWidth, strUnits)

        vIndices = getIndicesFromWindow(this, vTimeWindow, strUnits)
        dPeakFreq = getPeakFrequency(this, vTimeWindow, vFrequencyWindow, bWhiten)
        vPeakFreqs = getPeakFrequencies(this, mtxTimeWindows, vFrequencyWindow, cellSpectParams)

        cellSequenceEvents = refineRippleSequences(this, cellRippleEvents, varargin)
        nSection = getSection(this, objEvent)
    end
end
