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
classdef NeuralData
    properties (GetAccess = public, SetAccess = protected)
        Clu
        Laps
        Spike
        Track
        xml
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
            [filePath, baseFileName, ~] = fileparts(filename);

            load(fullfile(filePath, [baseFileName '_BehavElectrDataLFP.mat']));

            this.Clu = Clu;
            this.Laps = Laps;
            this.Spike = Spike;
            this.Track = Track;
            this.xml = xml;
        end
    end

    methods (Access = public)
        clusterSpikeTimes = groupSpikes(this)

        rate = sampleRate(this)

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