%
% DESCRIPTION:
%
%    A container for neural events and related data.
%
classdef Event
    properties (GetAccess = public, SetAccess = private)
        window, spikes, times, type
    end

    methods (Access = public)
        % ARGUMENTS:
        %   vTimeWindow:   a vector [start_time, end_time]
        %   vSpikeTimes:   the times at which neurons spike
        %   vSpikes:       the neurons that are spiking
        %
        % NOTE: vSpikeTimes and vSpikes must be the same length; the spike
        % times must all lie within the specified time window.
        function this = Event(vTimeWindow, vSpikeTimes, vSpikes, strType)
            assert(all(vSpikeTimes >= vTimeWindow(1)) ...
                   && all(vSpikeTimes <= vTimeWindow(2)), ...
                   'Please ensure that all times lie within the given window');

            this.window = vTimeWindow;

            [~, vOrder] = sort(vSpikeTimes);
            this.times = col(vSpikeTimes(vOrder));
            this.spikes = col(vSpikes(vOrder));

            if nargin < 4
                strType = '';
            end

            this.type = strType;
        end
    end

    methods (Access = public)
        function vActive = activeCells(this)
            vActive = unique(sequence(this));
        end

        function vSequence = sequence(this)
            vSequence = this.spikes;
        end

        function dDuration = duration(this)
            dDuration = endTime(this) - startTime(this);
        end

        function nLength = length(this)
            nLength = length(this.spikes);
        end

        function dTime = startTime(this)
            dTime = this.window(1);
        end

        function dTime = endTime(this)
            dTime = this.window(2);
        end

        function vTimes = firingTimes(this, nCell)
            if nargin < 2
                vTimes = this.times;
            else
                vTimes = this.times(sequence(this) == nCell);
            end
        end

        function cellTrains = spikeTrains(this, vCells, bShift)
            if nargin < 2 || isempty(vCells)
                vCells = 1 : max(activeCells(this));
            end

            if nargin < 3
                bShift = false;
            end

            if bShift
                fcnGetTrains = @(n) (firingTimes(this, n) - this.window(1));
            else
                fcnGetTrains = @this.firingTimes;
            end

            cellTrains = arrayfun(fcnGetTrains, col(vCells), ...
                                  'UniformOutput', false);
        end

        function plot(this, varargin)
            plotSpikeTrains(spikeTrains(this), this.window, varargin{:});
        end

        function plotSequence(this, varargin)
            % Create a new `Event` whose time information has been replaced
            % by an ordering.
            nLength = length(this);
            evtSequence = Event([1, nLength], 1 : nLength, sequence(this));

            % Now just plot the new `Event`.
            plot(evtSequence, varargin{:});
        end

        function vOrder = orderCells(this)
            vSequence = sequence(this);
            vNeurons = unique(sequence(this));
            vCentersOfMass = zeros(size(vNeurons));

            for i = 1 : length(vNeurons)
                vCentersOfMass(i) = mean(find(vSequence == vNeurons(i)));
            end

            [~, vOrder] = sort(vCentersOfMass);
            vOrder = vNeurons(vOrder);
        end

        function mtxBias = bias(this, dTime, nMax)
            if nargin < 2 || isempty(dTime)
                dTime = Inf;
            end

            if nargin < 3
                nMax = max(this.spikes);
            end

            % Initialize
            vCells = activeCells(this);
            nCells = length(vCells);
            cellTrains = spikeTrains(this, vCells);
            mtxCounts = sparse([], [], [], nMax, nMax, nCells^2);

            % Count
            for i = 1 : nCells - 1
                n1 = vCells(i);
                vTrain1 = cellTrains{i};

                for j = i + 1 : nCells
                    n2 = vCells(j);
                    vTrain2 = cellTrains{j};

                    mtxGaps = bsxfun(@minus, row(vTrain2), col(vTrain1));
                    mtxCounts(n1, n2) = nnz((mtxGaps > 0) & (mtxGaps < dTime));
                    mtxCounts(n2, n1) = nnz((mtxGaps < 0) & (mtxGaps > -dTime));
                end
            end

            % Normalize
            mtxBias = sparse(nMax, nMax);
            mtxSum = mtxCounts + mtxCounts';
            mtxDiff = mtxCounts - mtxCounts';
            vLocs = find(mtxSum);
            mtxBias(vLocs) = mtxDiff(vLocs) ./ mtxSum(vLocs);
        end
    end
end
