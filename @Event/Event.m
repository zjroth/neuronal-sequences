%
% DESCRIPTION:
%
%    A container for neural events and related data.
%
classdef Event
    properties (GetAccess = public, SetAccess = private)
        startTime, endTime, spikeSeries
    end

    methods (Access = public)
        % ARGUMENTS:
        %   vTimeWindow:   a vector [start_time, end_time]
        %   vSpikeTimes:   the times at which neurons spike
        %   vSpikes:       the neurons that are spiking
        %
        % NOTE: vSpikeTimes and vSpikes must be the same length; the spike
        % times must all lie within the specified time window.
        function this = Event(vTimeWindow, vSpikeTimes, vSpikes)
            assert(all(vSpikeTimes >= vTimeWindow(1)) ...
                   && all(vSpikeTimes <= vTimeWindow(2)), ...
                   'Please ensure that all times lie within the given window');

            this.startTime = vTimeWindow(1);
            this.endTime = vTimeWindow(2);

            [~, vOrder] = sort(vSpikeTimes);
            this.spikeSeries = TimeSeries(col(vSpikes(vOrder)), ...
                                          vSpikeTimes(vOrder));
        end
    end

    methods (Access = public)
        function vActive = activeCells(this)
            vActive = unique(sequence(this));
        end

        function vSequence = sequence(this)
            vSequence = this.spikeSeries.Data;
        end
    end
end