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
classdef RatData < handle
    properties (GetAccess = public, SetAccess = protected)
        pre
        musc
        post
    end

    methods (Access = public)
        %---------------------------------------------------------------
        %
        % USAGE:
        %
        %    obj = RatData()
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
        function this = RatData(strFolder)
            objData = matfile([strFolder, 'data.mat'], 'Writable', false);

            % Load the data from each of the files.
            this.pre = NeuralData([strFolder 'pre-muscimol/']);
            this.musc = NeuralData([strFolder 'muscimol/']);
            this.post = NeuralData([strFolder 'post-muscimol/']);

            % Set the current channels if they are specified in the data
            % file.
            if ~isempty(whos(objData, 'vChannels'))
                cellChannels = num2cell(objData.vChannels);

                this.pre.setCurrentChannels(cellChannels{:});
                this.musc.setCurrentChannels(cellChannels{:});
                this.post.setCurrentChannels(cellChannels{:});
            end
        end
    end

    methods (Access = public)
        plotSpikeTrains(this, vSequenceNums, varargin)
        cellSeqs = getRipples(this, varargin)
        cellSeqs = getRippleSequences(this, varargin)
        [strSection, nSectionRipple] = identifyRipple(this, nRipple)
        vOrder = sortNeuronsForRipple(this, nRipple, varargin)
        cellTrains = getSpikeTrains(this, bRemoveInterneurons)
        plotRipple(this, nRipple, varargin)
        compareSpikeTrains(this, nSeqX, nSeqY)
        compareRippleSpikeTrains(this, nSeqX, nSeqY, vActiveNeurons)
        [mtxEvents, vPreCounts, vMuscCounts, vPostCounts] = getEvents(this)
    end
end