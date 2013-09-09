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
        function this = RatData(strRatName, strDate)
            strBaseDir = '~/data/pastalkova/';

            if ~strcmp(strRatName, 'A543') || ~strcmp(strDate, '2012-04-22')
                error(['unknown recording; please modify constructor to use ' ...
                       'this data']);
            else
                cellChannels = { 35, 46, 34 };
                structParams.interneurons = [49, 66, 77, 90];

                % These neurons were taken from Eva's list:
                %    left: [91, 74, 109, 125, 36, 83, 30, 123, 79, 86, 117]
                %    right: [31, 86, 11, 95, 82, 106, 109, 30, 79, 16, ...
                %            117, 108, 73, 29, 87, 116, 24, 52]
                %
                % The following list was constructed by me from the above list.
                % Neurons were duplicated if multiple place fields seemed to exist,
                % and neurons were deleted if a place field did not seem to exist.
                %structParams.placeCellOrdering =  [ ...
                %    26, 24, 16, 22, 2, 14, 24, 28, 20, 1, 12, 13, 9, 6, 2, 8, ...
                %    29, 4, 6, 27, 8, 2, 28, 7, 3, 12, 19, 24, 15, 29 ...
                %];
                structParams.placeCellOrdering = [ ...
                    31, 86, 11, 95, 82, 106, 109, 30, 79, 16, 117, 108, 73, ...
                    29, 87, 116, 24, 52, 91, 74, 109, 125, 36, 83, 30,123, ...
                    79, 86, 117];

                % Load the data from each of the files.
                strFile = [strRatName '/' strDate '/pre-muscimol/'];
                this.pre = NeuralData([strBaseDir strFile]);
                this.pre.parameters = structParams;
                this.pre.setCurrentChannels(cellChannels{:});

                strFile = [strRatName '/' strDate '/muscimol/'];
                this.musc = NeuralData([strBaseDir strFile]);
                this.musc.parameters = structParams;
                this.musc.setCurrentChannels(cellChannels{:});

                strFile = [strRatName '/' strDate '/post-muscimol/'];
                this.post = NeuralData([strBaseDir strFile]);
                this.post.parameters = structParams;
                this.post.setCurrentChannels(cellChannels{:});
            end
        end
    end

    methods (Access = public)
        plotSpikeTrains(this, vSequenceNums, varargin)
        cellSeqs = getRipples(this, varargin)
        cellSeqs = getRippleSequences(this, varargin)
        [strSection, nSectionRipple] = identifyRipple(this, nRipple)
    end
end