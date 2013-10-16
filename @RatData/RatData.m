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
            this.pre = NeuralData(fullfile(strFolder, 'pre-muscimol/'));
            this.musc = NeuralData(fullfile(strFolder, 'muscimol/'));
            this.post = NeuralData(fullfile(strFolder, 'post-muscimol/'));
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