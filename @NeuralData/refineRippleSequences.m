% USAGE:
%    cellSequenceEvents = refineRippleSequences(this, cellRippleEvents, varargin)
%
% DESCRIPTION:
%    .
%
% ARGUMENTS:
%    .
%       .
%
% OPTIONAL PARAMETERS:
%    . (default: )
%       .
%
% RETURNS:
%    .
%       .
function cellSequenceEvents = refineRippleSequences(this, cellRippleEvents, varargin)
    %=======================================================================
    % Default optional parameter values
    %=======================================================================
    dIntraSequenceGap = 0.015;          % Spikes separated by no more than 15 ms
    dMaxDuration = 0.250;               % Maximum duration of 250 ms
    nMinActive = 5;                     % At least 5 active neurons
    dEdgeBuffer = 0.03;                 % Roughly 1/4 of a theta cycle
    dSilenceBuffer = 0.06;              % Roughly 1/2 of a theta cycle

    %=======================================================================
    % Initialization and value-checking
    %=======================================================================

    % Parse the named parameter list in `varargin`.
    cellValidParams = {'dIntraSequenceGap', 'dMaxDuration', 'nMinActive', ...
                       'dEdgeBuffer', 'dSilenceBuffer'};
    parseNamedParams(varargin, cellValidParams);

    %=======================================================================
    % Actual computations
    %=======================================================================

    %
    vSequenceIndices = [];
    [vEntireSequence, vAllSpikeTimes] = getSequence(this, [-Inf, Inf]);

    % We're joining two spikes into a single sequence if there is a short enough
    % period of time between them. This means that a sequence can be determined
    % strictly from the list of spike times. Find this list of (inherent)
    % sequence time windows.
    vSeparation = diff(vAllSpikeTimes);
    [mtxIntervals, vValues] = constant(vSeparation <= dIntraSequenceGap);
    mtxIntervals = mtxIntervals(vValues, :);
    mtxIntervals(:, 2) = mtxIntervals(:, 2) + 1;

    mtxWindows = vAllSpikeTimes(mtxIntervals);

    % Extract the windows in which ripples are happening (including the time
    % buffer).
    mtxRippleWindows = cell2mat( ...
        cellfun(@(e) e.window, cellRippleEvents, 'UniformOutput', false));
    mtxRippleWindows = bsxfun(@plus, mtxRippleWindows, ...
                              dEdgeBuffer * [-1, 1]);

    % Join sequence windows that overlap with a common ripple event.
    for i = 1 : size(mtxRippleWindows, 1)
        vWindow = mtxRippleWindows(i, :);
        vTouching = intervalstouch(vWindow, mtxWindows);

        if nnz(vTouching) > 1
            vTouching = find(vTouching);

            mtxWindows(vTouching(1), 2) = mtxWindows(vTouching(end), 2);
            mtxWindows(vTouching(2 : end), :) = [];

            mtxIntervals(vTouching(1), 2) = mtxIntervals(vTouching(end), 2);
            mtxIntervals(vTouching(2 : end), :) = [];
        end
    end

    % Keep those windows that overlap with a ripple event.
    vKeep = cellfun(@(w) any(intervalstouch(w, mtxRippleWindows)), ...
                    rows(mtxWindows));

    % Ensure a minimum amount of silence before and after a sequence.
    for i = row(find(vKeep))
        if (i > 1) && (i < size(mtxWindows, 1))
            vKeep(i) = ...
                (mtxWindows(i, 1) - mtxWindows(i - 1, 2) >= dSilenceBuffer) && ...
                (mtxWindows(i + 1, 1) - mtxWindows(i, 2) >= dSilenceBuffer);
        end
    end

    % Create the sequence events for the list of windows.
    mtxWindows = mtxWindows(vKeep, :);
    mtxIntervals = mtxIntervals(vKeep, :);
    nEvents = size(mtxWindows, 1);
    cellSequenceEvents = cell(nEvents, 1);

    for i = 1 : nEvents
        % Get the time window during which this sequence is occurring. Give the
        % first and last spike a little buffer room.
        vWindow = mtxWindows(i, :) + dIntraSequenceGap * [-0.25, 0.25];

        % Extract the spikes and spike times for this sequence.
        vIndices = (mtxIntervals(i, 1) : mtxIntervals(i, 2));
        vSpikeTimes = vAllSpikeTimes(vIndices);
        vSpikes = vEntireSequence(vIndices);

        % Store the sequence event.
        cellSequenceEvents{i} = Event(vWindow, vSpikeTimes, vSpikes, 'ripple_seq');
    end

    % Keep only those events that don't last too long and that have enough
    % spiking.
    fcnIsGoodEvent = @(e) ...
        (length(activeCells(e)) >= nMinActive) & ...
        (diff(e.window) <= dMaxDuration);
    cellSequenceEvents = cellSequenceEvents( ...
        cellfun(fcnIsGoodEvent, cellSequenceEvents));
end

function vSpikes = getSpikeTimes(this)
    vSpikes = col(getSpike(this, 'res')) ./ sampleRate(this);
end
