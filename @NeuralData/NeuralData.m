%
% DESCRIPTION:
%
%    Provide convenient access to neural data related to ripple detection.
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
        function this = NeuralData(folder)
            load([folder '.mat']);

            this.Clu = Clu;
            this.Laps = Laps;
            this.Spike = Spike;
            this.Track = Track;
            this.xml = xml;
        end
    end

    methods (Access = public)
        tms = ripples(this)
        tms = lfp(this)
        % clln = CodeComplex(this)
        %
        % cllnDecoded = Decode(this, clln)
        %
        % cllnDecoded = DecodeMAP(this, clln)
        %
        % d = Distance(this, x, y)
        %
        % gph = Graph(this)
        %
        % gph = CodewordGraph(this, tol)
        %
        % iLength = Length(this)
        %
        % cllnRand = RandomSample(this, iSize)
        %
        % r = Rate(this)
        %
        % SetDistribution(this, cvDistribution)
        %
        % SetMetric(this, fcnHandle)
        %
        % codeNew = Shuffle(this)
        %
        % iSize = Size(this)
        %
        % s = Sparsity(this)
        %
        % mtx = ToMatrix(this)
    end
end