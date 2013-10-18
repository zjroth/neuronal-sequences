%
% USAGE:
%
%    plotSpikeTrains(cellTrains, vTimeWindow, vOrdering, mtxColors)
%
% DESCRIPTION:
%
%    Plot the given spike trains
%
% ARGUMENTS:
%
%    cellTrains
%
%       The spike trains to plot as a cell array where each entry of the cell
%       array represents one neuron's spike train. Each entry of this cell
%       array should be a vector of doubles (time values).
%
%    vTimeWindow (default: based on `cellTrains`)
%
%       The window to display
%
%    vOrdering (default: `1 : length(cellTrains)`)
%
%       The ordering to use when displaying the neurons. This does not affect
%       the color used to display a given spike train.
%
%    mtxColors (default: `lines()`)
%
%       A matrix with three columns, each row of which represents an RGB color.
%       The colors will be used cyclically.
%
function plotSpikeTrains(cellTrains, vTimeWindow, vOrdering, mtxColors)
    % Set the default time window to be just as wide as it has to be.
    if nargin < 2 || isempty(vTimeWindow)
        dMinSpike = min(cellfun(@myMin, cellTrains));
        dMaxSpike = max(cellfun(@myMax, cellTrains));
        vTimeWindow = [dMinSpike, dMaxSpike];
    end

    % If no ordering was provided, use the natural one.
    if nargin < 3 || isempty(vOrdering)
        vOrdering = (1 : length(cellTrains));
    end

    % Set a default coloring scheme.
    if nargin < 4
        mtxColors = lines();
    end

    % Store the start/end of the ripple window, and store the number of colors
    % that we have to work with.
    dMinTime = vTimeWindow(1);
    dMaxTime = vTimeWindow(2);
    nColors = size(mtxColors, 1);

    % If a custom ordering wasn't provided, just use the default order.
    if ~exist('vOrdering', 'var')
        vOrdering = (1 : length(cellTrains));
    end

    % Since each train will be plotted individually, we need to tell matlab not
    % to overwrite what has already been plotted.
    hold('on');

    % For each neuron's spike train, plot that spike train along a horizontal
    % line.
    for j = 1 : length(vOrdering)
        % Extract the current neuron number.
        nCurrNeuron = vOrdering(j);

        % Extract the portion of the current train that lives in the provided
        % time window.
        vTrain = cellTrains{nCurrNeuron};
        vTrain = vTrain(dMinTime <= vTrain & vTrain <= dMaxTime);

        % The color of this spike train is determined by the actual neuron
        % number, but the height of the plotted spike train is determined by the
        % index of the current neuron in the ordering.
        vSpikeColor = mtxColors(mod(nCurrNeuron - 1, nColors) + 1, :);
        plot(vTrain, j * ones(size(vTrain)), '.', 'Color', vSpikeColor);
    end

    % Now that everything has been plotted, tidy up.
    hold('off');
    xlim([dMinTime, dMaxTime]);
    ylim([0, length(vOrdering) + 1]);
    set(gca, 'YTick', []);
    set(gca, 'YTickLabel', []);
end

function dMax = myMax(v)
    if isempty(v)
        dMax = -Inf;
    else
        dMax = max(v);
    end
end

function dMin = myMin(v)
    if isempty(v)
        dMin = Inf;
    else
        dMin = min(v);
    end
end