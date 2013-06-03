function hndl = plotRipple(timeData, data, fShp, fRip, event)
    colors = [0.5 0.5 0.5; ...
              0.0 0.0 0.0; ...
              0.5 0.5 0.5];

    % If time data wasn't provided...
    if (isempty(timeData))
        timeData = (1 : size(data, 1))';
    end

    % Init the figure to return.
    hndl = figure(100);

    % Plot the three channels; and draw vertical lines at the
    % start, peak, and end of the ripple.
    subplot(4, 1, 1:2); cla; hold on;
    plot(timeData, data(:, 1) - mean(data(:, 1)), 'b');
    plot(timeData, data(:, 2) - mean(data(:, 2)), 'r');
    plot(timeData, data(:, 3) - mean(data(:, 3)), 'g');
    vertlines(gca, event, colors);
    xlabel('milliseconds');

    % Plot the filtered "sharp wave".
    subplot(4,1,3); cla; hold on;
    plot(timeData, fShp, 'k');
    vertlines(gca, event, colors);
    xlabel('milliseconds');

    % Plot the "ripple".
    subplot(4,1,4); cla; hold on;
    plot(timeData, fRip, 'r');
    vertlines(gca, event, colors);
    xlabel('milliseconds');
end

function vertline(axesHandle, x, color)
    yLimits = get(axesHandle, 'YLim');
    line([x, x], yLimits, 'Color', color);
end

function vertlines(axesHandle, xs, colors)
    for i = 1 : length(xs)
        vertline(gca, xs(i), colors(i, :));
    end
end