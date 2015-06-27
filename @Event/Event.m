% DESCRIPTION:
%    A container for neural events and related data.
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
        function vWindow = getWindow(this)
            vWindow = this.window;
        end

        function setWindow(this, vWindow)
            this.window = vWindow;
        end

        function setType(this, strValue)
            assert(@ischar, strValue, 'Event.setType: type value must be a string');
            this.type = strValue;
        end

        function vActive = activeCells(this)
            vActive = unique(sequence(this));
        end

        function nActive = numActive(this)
            nActive = length(activeCells(this));
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

        % USAGE:
        %    plot(this, ...)
        %
        % DESCRIPTION:
        %    Create a spike-raster plot for the given event.
        %
        % OPTIONAL PARAMETERS:
        %    vOrdering (default: `activeCells(this)`)
        %       The ordering to use when displaying the neurons. This does not affect
        %       the color used to display a given spike train.
        %    mtxColors (default: `lines()`)
        %       A three-column matrix, each row of which represents an RGB color.
        %       The colors will be used cyclically.
        %    axPlot (default: `gca()`)
        function plot(this, varargin)
            % Optional parameters
            vOrdering = activeCells(this);
            mtxColors = lines();
            axPlot = gca();

            cellAllowedParams = {'axPlot', 'vOrdering', 'mtxColors'};
            parseNamedParams(varargin, cellAllowedParams);

            % Get the spike trains.
            cellTrains = spikeTrains(this);

            % Store the number of colors that we have to work with.
            nColors = size(mtxColors, 1);

            % Clear the current axes. Also, since each train will be plotted
            % individually, we need to tell matlab not to overwrite what has already
            % been plotted.
            cla(axPlot);
            hold('on');

            % For each neuron's spike train, plot that spike train along a horizontal
            % line.
            nNumPlotted = 0;

            for j = 1 : length(vOrdering)
                % Extract the current neuron number. Get the spike train for the current neuron.
                nCurrNeuron = vOrdering(j);
                vTrain = cellTrains{nCurrNeuron};

                % Only plot something if there are spike to plot.
                if ~isempty(vTrain)
                    % The color of this spike train is determined by the actual neuron
                    % number, but the height of the plotted spike train is determined by the
                    % number of already-plotted trains.
                    vSpikeColor = mtxColors(mod(nCurrNeuron - 1, nColors) + 1, :);
                    plot(axPlot, vTrain, j * ones(size(vTrain)), ...
                         '.', 'Color', vSpikeColor);
                end
            end

            % Now that everything has been plotted, tidy up.
            hold('off');
            xlim(this.window);
            ylim([0, length(vOrdering) + 1]);
            set(gca, 'YTickLabel', []);
        end

        function plotSequence(this, varargin)
            % Create a new `Event` whose time information has been replaced by an
            % ordering. Then just plot the new `Event`.
            nLength = length(this);
            evtSequence = Event([1, nLength], 1 : nLength, sequence(this));

            plot(evtSequence, varargin{:});
        end

        function [vCentersOfMass, vNeurons] = centerofmass(this)
            vSequence = sequence(this);
            vNeurons = activeCells(this);
            nNeurons = length(vNeurons);
            vCentersOfMass = zeros(nNeurons, 1);

            for i = 1 : nNeurons
                vCentersOfMass(i) = mean(find(vSequence == vNeurons(i)));
            end

            vCentersOfMass = (2 * vCentersOfMass - 1) / length(vSequence) - 1;
        end

        function vOrder = orderCells(this)
            [vCenters, vNeurons] = centerofmass(this);
            [~, vOrder] = sort(vCenters);
            vOrder = vNeurons(vOrder);
        end

        function mtxBias = bias(this, dTime, nMax)
            if nargin < 2 || isempty(dTime)
                dTime = Inf;
            end

            if nargin < 3
                nMax = max(this.spikes);
            end

            if isinf(dTime)
                mtxBias = orderBias(sequence(this));
            else
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
end
