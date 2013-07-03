function hndl = plotRipples(ripples, lfpTriple, data, varargin)
    ripplePadding = 0.1;
    events = (1 : size(ripples, 1));
    parseNamedParams();

    spikeTrains = groupSpikes(data);
    trackData = data.Track;
    spikeTrainSampleRate = sampleRate(data);

    if ~exist('neurons', 'var')
       neurons = (1 : length(spikeTrains));
    end

    % Create a full-screen figure.
    hdl = figure();
    screenSize = get(0, 'ScreenSize');
    set(hdl, 'Position', [0 0 screenSize(3) screenSize(4)]);
    title('test');

    colors = get(gca, 'ColorOrder');
    numColors = size(colors, 1);

    h(3) = subplot(2, 2, [2, 4]);
    plot(trackData.xPix(1:10:end), trackData.yPix(1:10:end), '.', 'Color', [0.75, 0.75, 0.75]);
    tmp = [];

    for i = events %1 : size(ripples, 1)
        ripple = ripples(i, :);
        speed = data.Track.speed_MMsec(round(ripple(2) * spikeTrainSampleRate));
        set(gcf, 'name', ...
            ['----------Ripple ' num2str(i) '----------' ...
             'Speed: ' num2str(speed) ' mm/sec----------' ...
             'Width: ' num2str((ripple(3) - ripple(1)) * 1000) ' ms----------']);

        timeWindow = [ripple(1) - ripplePadding, ripple(3) + ripplePadding];
        minTime = timeWindow(1);
        maxTime = timeWindow(2);

        % Plot the main ripple events over the LFP-triple.
        h(1) = subplot(2, 2, 1);
        localLfpTriple = subseries(lfpTriple, minTime, maxTime);
        plot(localLfpTriple.Time, localLfpTriple.Data);
        %ylim([-2000, 2000]);

        for j = 1 : size(ripples, 1)
            if (ripples(j, 1) > minTime || ripples(j, 3) < maxTime)
                showRipple(ripples(j, :));
            end
        end

        title(['LFPs and Ripple Event ' num2str(i)]);
        ylabel('');
        xlim(timeWindow);
        set(gca, 'Color', [1, 1, 1]);

        h(2) = subplot(2, 2, 3);
        hold('on');

        firingRates = zeros(size(neurons));
        for j = 1 : length(neurons)
            firingRates(j) = length(spikeTrains{neurons(j)}) / ...
                size(data.Track.xPix, 1) * sampleRate(data);
        end

        for j = 1 : length(neurons) %1 : size(spikeTrains, 1)
            if firingRates(j) < 10
                train = spikeTrains{neurons(j)} / spikeTrainSampleRate;
                train = train(minTime <= train & train <= maxTime);

                spikeColor = colors(mod(j, numColors) + 1, :);
                plot(train, j * ones(size(train)), '.', 'Color', spikeColor);
                %set(gcf,'windowbuttonmotionfcn',your_callback);
            end
        end

        title('Spike Raster Plot');
        ylabel('Neuron Number');
        xlabel('Time (seconds)');
        xlim(timeWindow);
        %ylim([min(neurons) - 1, max(neurons) + 1]);
        ylim([0, length(neurons) + 1]);
        set(gca, 'Color', [1, 1, 1]);

        hold('off');

        subplot(2, 2, [2, 4]);
        hold('on');
        delete(tmp);

        trackTimes = (0 : size(trackData.xPix, 1) - 1) / spikeTrainSampleRate;

        trackSection.xPix = withinRange(trackData.xPix, trackTimes);
        trackSection.yPix = withinRange(trackData.yPix, trackTimes);
        tmp(1) = plot(trackSection.xPix, trackSection.yPix, '.', 'Color', [0.25, 0.25, 0.25]);

        idxs = round(withinRange(ripples(:, 2)) * spikeTrainSampleRate);
        tmp(2) = plot(trackData.xPix(idxs), trackData.yPix(idxs), 'r.');
        hold('off');
        set(gca, 'Color', [1, 1, 1]);

        %linkaxes(h(1:2), 'x');

        pause();
    end

    function newData = withinRange(data, time)
        if ~exist('time', 'var')
            time = data;
        end

        newData = data(minTime <= time & time <= maxTime);
    end
end

function showRipple(ripple, varargin)
    rippleColor = [0.5, 0.5, 0.5];
    rippleOpacity = 0.3;

    parseNamedParams();

    ylims = get(gca, 'YLim');
    y_min = ylims(1);
    y_max = ylims(2);

    hold('on');

    fill([ripple(1), ripple(1), ripple(3), ripple(3)], ...
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
