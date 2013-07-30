% neuronSet --- can have the following forms:
%   - A vector of integers specifying a collection of neurons to restrict to
%   (order is unimportant).
%
%   - (NOT IMPLEMENTED) An n by 2 matrix whose first column is as above and
%   whose second column specifies an activity pattern for the first column.
%   Row order is unimportant.
%
% cellOrderings --- a cell array whose entries can have the following forms:
%   - A vector of integers specifying an ordering for neurons. All cell
%   orderings will be intersected with the provided `neuronSet`; hence, prior
%   restriction to the neuron set is not necessary for the provided orderings.
%
%   - (NOT IMPLEMENTED) A vector cell array whose first entry is as above. The
%   subsequent entries provide options for individual orderings. Some
%   possible options:
%     - A specific activity pattern to display
function hndl = plotRipple(nRipple, lfpTriple, data, varargin)
    %=======================================================================
    % Default optional parameter values
    %=======================================================================
    ripplePadding = 0.06;

    neuronSet = [];
    activityPattern = [];
    cellOrderings = {};

    createFigure = false;
    colors = lines();

    removeInterneurons = false;

    % Retrieve the passed-in optional parameter values.
    parseNamedParams();

    %=======================================================================
    % Initialization and value-checking
    %=======================================================================

    % Retrieve the collection of ripples from the data, and remove duplicates
    % from the collection of neurons under consideration.
    ripples = data.getRipples() / sampleRate(data);

    if ~isempty(activityPattern)
        assert(isvector(activityPattern) && ...
            length(activityPattern) == length(neuronSet), ...
            'The neuron set and activity pattern must be vectors of the same length.');
    end

    spikeTrains = getSpikeTrains(data);

    if isempty(neuronSet)
        neuronSet = (1 : length(spikeTrains));
    end

    % Store some information about the event that we're plotting.
    ripple = ripples(nRipple, :);
    timeWindow = [ripple(1) - ripplePadding, ripple(3) + ripplePadding];
    minTime = timeWindow(1);
    maxTime = timeWindow(2);

    % Interneurons are distracting. Remove them.
    if removeInterneurons && isfield(data.parameters, 'interneurons')
        spikeTrains(data.parameters.interneurons) = {[]};
    end

    % Determine the number of rows that our figure will have (for use in the subplot
    % command). For now, the plots will have 3 columns.
    nPlotRows = length(cellOrderings) + 1;
    nPlotCols = 3;

    % Create a (full-screen) figure if requested.
    if createFigure
        fig = figure();
        screenSize = get(0, 'ScreenSize');
        set(fig, 'Position', [0 0 screenSize(3) screenSize(4)]);
    end

    %=======================================================================
    % Plotting
    %=======================================================================

    % Clear the figure.
    clf();

    % Set the window's title.
    speed = data.Track.speed_MMsec(round(ripple(2) * sampleRate(data)));
    set(gcf, 'name', ...
        ['----------Ripple ' num2str(nRipple) '----------' ...
         'Speed: ' num2str(speed) ' mm/sec----------' ...
         'Width: ' num2str((ripple(3) - ripple(1)) * 1000) ' ms----------']);

    % Plot the main ripple events over the LFP-triple.
    h(1) = subplot(nPlotRows, nPlotCols, (1 : nPlotCols));
    localLfpTriple = subseries(lfpTriple, minTime, maxTime);
    plot(localLfpTriple.Time, localLfpTriple.Data);
    % showRipples(ripples, timeWindow);
    PlotIntervals([minTime, ripple(1); ripple(3), maxTime], 'rectangles');
    vline(ripple(2), 'color', [1 0 0]);

    % Set plot niceties.
    xticklabels = get(gca, 'XTickLabel');
    set(gca, 'Layer', 'top', 'XTickLabel', {[]});
    legend('Low', 'Main', 'High');
    title(['LFPs and Ripple Event ' num2str(nRipple)]);
    ylabel('');
    xlim(timeWindow);
    set(gca, 'Color', [1, 1, 1]);

    % Assign the callback for moving ripple edges.
    fcnRedraw = @() plotRipple(nRipple, lfpTriple, data, varargin{:});
    set(h(1), 'ButtonDownFcn', ...
        { @moveRippleEdge, h(1), data, nRipple, fcnRedraw });

    rippleActivity = data.getRippleActivity(nRipple);

    % For each of the provided orderings, create plots of the associated spike
    % trains and activity patterns.
    for i = 1 : length(cellOrderings)
        % Retrieve the current ordering and intersect those cells with
        % the provided `neuronSet`.
        ordering = cellOrderings{i};
        orderingDesc = 'Spike Raster';

        if isa(ordering, 'cell')
            orderingDesc = ordering{2};
            ordering = ordering{1};
        end

        [ordering, ~, idxs] = intersect(ordering, neuronSet, 'stable');

        % Plot the spike trains.
        vSubplotLocs = i * nPlotCols + (1 : nPlotCols);
        h(i + 1) = subplot(nPlotRows, nPlotCols, vSubplotLocs);
        plotSpikeTrains(data, ripple, spikeTrains(ordering), timeWindow, ...
            colors, 'plotTitle', orderingDesc, 'neuronNumbers', ordering);
        % set(gca, 'XTickLabel', {[]});

        % % Plot the activity pattern. Make the first such plot larger.
        % subplot(nPlotRows, nPlotCols, (i + (i > 1) : i + 1) * nPlotCols);
        % mtxActivity = rippleActivity(ordering);
        %
        % if ~isempty(activityPattern)
        %     mtxActivity = [mtxActivity, activityPattern(idxs)];
        % end
        %
        % plotNeuronActivity(mtxActivity);
        % colorbar();
    end

    set(h(end), 'XTickLabelMode', 'auto')
    xlabel(h(end), 'Time (seconds)');
end

%=======================================================================
% Helper functions
%=======================================================================

function bSuccess = moveRippleEdge(hObject, anEmptyArray, lfpAxes, data, nRipple, callback)
    [x, ~, b] = ginput(1);
    bSuccess = (lfpAxes == gca);

    if bSuccess
        ripple = data.getRipples(nRipple);
        x = round(x * sampleRate(data));

        if b == 1
            % data.setRipple(nRipple, [x, ripple(2:3)]);
            data.modifyRipple(nRipple, x, ripple(3));
            callback();
        elseif b == 3
            % data.setRipple(nRipple, [ripple(1:2), x]);
            data.modifyRipple(nRipple, ripple(1), x);
            callback();
        end
    end
end

function plotNeuronActivity(mtx)
    if ~isempty(mtx)
        pcolor(padarray(double(mtx), [1, 1], 'post'));

        if size(mtx, 2) == 2
            set(gca, 'XTick', [1.5, 2.5]);
            set(gca, 'XTickLabel', {'Current', 'Master'});
        else % size == 1
            set(gca, 'XTick', 1.5);
            set(gca, 'XTickLabel', {'Current'});
        end

        title('Neuron Activity');
        colormap([0.1, 0.1, 0.1; jet()]);
    else
        cla();
    end
end

function plotSpikeTrains(data, ripple, trains, timeWindow, colors, varargin)
    plotTitle = 'Spike Raster Plot';
    neuronNumbers = (1 : length(trains));
    parseNamedParams();
    set(gca, 'Layer', 'top');
    hold('on');

    minTime = timeWindow(1); % ripple(1);
    maxTime = timeWindow(2); % ripple(3);
    nColors = size(colors, 1);

    firingRates = zeros(size(trains));
    for j = 1 : length(trains)
        firingRates(j) = length(trains{j}) / ...
            size(data.Track.xPix, 1) * sampleRate(data);
    end

    for j = 1 : size(trains, 1)
        if firingRates(j) < Inf
            train = trains{j} / sampleRate(data);
            train = train(minTime <= train & train <= maxTime);

            spikeColor = colors(mod(neuronNumbers(j), nColors) + 1, :);
            % plot(mean(train(ripple(1) <= train & train <= ripple(3))), j, ...
            %     '.', 'MarkerSize', 20, 'Color', [0.75, 0.75, 0.75]);
            plot(train, j * ones(size(train)), '.', 'Color', spikeColor);
            % if length(train) > 0
            %     PlotTicks(train, j * ones(size(train)), 'Color', spikeColor);
            % end
        end
    end

    title(plotTitle);
    ylabel('Neuron');
    % xlabel('Time (seconds)');
    xlim(timeWindow);
    ylim([0, length(trains) + 1]);
    set(gca, 'Color', [1, 1, 1]);

    PlotIntervals([minTime, ripple(1); ripple(3), maxTime], 'rectangles');

    hold('off');
end

function hndls = showRipples(ripples, timeWindow)
    hndls = zeros(size(ripples, 1), 1);

    minTime = timeWindow(1);
    maxTime = timeWindow(2);

    for j = 1 : size(ripples, 1)
        if (ripples(j, 1) < maxTime && ripples(j, 3) > minTime)
            hndls(j) = showRipple(ripples(j, :));
        end
    end
end

function hndl = showRipple(ripple, varargin)
    rippleColor = [0.5, 0.5, 0.5];
    rippleOpacity = 0.3;

    parseNamedParams();

    ylims = get(gca, 'YLim');
    y_min = ylims(1);
    y_max = ylims(2);

    hold('on');

    hndl = fill([ripple(1), ripple(1), ripple(3), ripple(3)], ...
         [y_min, y_max, y_max, y_min], ...
         rippleColor, ...
         'FaceAlpha', rippleOpacity);

    vline(ripple(2), 'color', [1 0 0]);

    hold('off');
end

function ts_new = subseries(ts, mn, mx)
    idxs = (ts.Time > mn & ts.Time < mx);
    ts_new = getsamples(ts, idxs);
end
