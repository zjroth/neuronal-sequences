function hndl = plotRipple(nRipple, lfpTriple, data, varargin)
    ripplePadding = 0.1;
    ripples = data.getRipples() / sampleRate(data);
    createFigure = false;
    masterRipple = 1;
    parseNamedParams();

    spikeTrains = getSpikeTrains(data);

    if isfield(data.parameters, 'interneurons')
        spikeTrains(data.parameters.interneurons) = {[]};
    end

    neurons = sortNeuronsForRipple(data, masterRipple, 'restrictToActive', true);
    activeMaster = getNeuronActivity(data, spikeTrains, ripples(masterRipple, [1, 3]) * sampleRate(data));

    % Create a full-screen figure.
    if createFigure
        hdl = figure();
        screenSize = get(0, 'ScreenSize');
        set(hdl, 'Position', [0 0 screenSize(3) screenSize(4)]);
        title('test');
    else
        hdl = gcf;
    end

    colors = lines(); %get(gca, 'ColorOrder');
    numColors = size(colors, 1);

    ripple = ripples(nRipple, :);
    speed = data.Track.speed_MMsec(round(ripple(2) * sampleRate(data)));
    set(gcf, 'name', ...
        ['----------Ripple ' num2str(nRipple) '----------' ...
         'Speed: ' num2str(speed) ' mm/sec----------' ...
         'Width: ' num2str((ripple(3) - ripple(1)) * 1000) ' ms----------']);

    timeWindow = [ripple(1) - ripplePadding, ripple(3) + ripplePadding];
    minTime = timeWindow(1);
    maxTime = timeWindow(2);

    % Plot the main ripple events over the LFP-triple.
    h(1) = subplot(3, 4, 1:3);
    %lfpTriple = [lowLfp(data), mainLfp(data), highLfp(data)];
    %lfpTriple = bsxfun(@minus, lfpTriple, mean(lfpTriple, 1));
    %vTimeData = (0 : size(lfpTriple, 1) - 1) / rawSampleRate(data);
    %vLfpIndices = (minTime <= vTimeData & vTimeData <= maxTime);
    %plot(vTimeData(vLfpIndices), lfpTriple(vLfpIndices, :));
    localLfpTriple = subseries(lfpTriple, minTime, maxTime);
    plot(localLfpTriple.Time, localLfpTriple.Data);
    showRipples(ripples, timeWindow);
    legend('Low', 'Main', 'High');

    this = @() plotRipple(nRipple, lfpTriple, data, varargin{:});

    set(h(1), 'ButtonDownFcn', ...
        { @moveRippleEdge, h(1), data, nRipple, this });

    title(['LFPs and Ripple Event ' num2str(nRipple)]);
    ylabel('');
    xlim(timeWindow);
    set(gca, 'Color', [1, 1, 1]);

    h(2) = subplot(3, 4, 5:7);
    neurons2 = sortNeuronsForRipple(data, nRipple, 'restrictToActive', true);
    plotSpikeTrains(data, ripple, spikeTrains(neurons2), timeWindow, colors);

    h(3) = subplot(3, 4, [4, 8]);
    active = getNeuronActivity(data, spikeTrains, ripple([1, 3]) * sampleRate(data));
    plotNeuronActivity([(active > 0), (activeMaster > 0)], masterRipple);

    h(4) = subplot(3, 4, 9:11);
    plotSpikeTrains(data, ripple, spikeTrains(neurons), timeWindow, colors);

    h(3) = subplot(3, 4, 12);
    plotNeuronActivity([active(neurons), activeMaster(neurons)], masterRipple);
    colorbar();
end

function bSuccess = moveRippleEdge(hObject, anEmptyArray, lfpAxes, data, nRipple, callback)
    [x, ~, b] = ginput(1);
    bSuccess = (lfpAxes == gca);

    if bSuccess
        ripple = data.getRipples(nRipple);
        x = round(x * sampleRate(data));

        if b == 1
            data.setRipple(nRipple, [x, ripple(2:3)]);
            callback();
        elseif b == 3
            data.setRipple(nRipple, [ripple(1:2), x]);
            callback();
        end
    end
end

function plotNeuronActivity(mtx, num)
    pcolor(padarray(double(mtx), [1, 1], 'post'));
    set(gca, 'XTickLabel', {[], 'Current', [], ['Ripple ' num2str(num)], []})
    colormap([0, 0, 0; jet()]);
end

function activeNeurons = getNeuronActivity(data, trains, timeWindow)
    minTime = timeWindow(1);
    maxTime = timeWindow(2);

    fcn = @(v) nnz(v(minTime <= v & v <= maxTime));
    activeNeurons = cellfun(fcn, trains);
end

function plotSpikeTrains(data, ripple, trains, timeWindow, colors)
    hold('on');

    minTime = timeWindow(1);
    maxTime = timeWindow(2);
    numColors = size(colors, 1);

    firingRates = zeros(size(trains));
    for j = 1 : length(trains)
        firingRates(j) = length(trains{j}) / ...
            size(data.Track.xPix, 1) * sampleRate(data);
    end

    for j = 1 : size(trains, 1)
        if firingRates(j) < Inf
            train = trains{j} / sampleRate(data);
            train = train(minTime <= train & train <= maxTime);

            spikeColor = colors(mod(j, numColors) + 1, :);
            % plot(mean(train(ripple(1) <= train & train <= ripple(3))), j, ...
            %     '.', 'MarkerSize', 20, 'Color', [0.75, 0.75, 0.75]);
            plot(train, j * ones(size(train)), '.', 'Color', spikeColor);
        end
    end

    title('Spike Raster Plot');
    ylabel('Neuron Number');
    xlabel('Time (seconds)');
    xlim(timeWindow);
    ylim([0, length(trains) + 1]);
    set(gca, 'Color', [1, 1, 1]);

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
