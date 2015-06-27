function viewEvent(nd, evt, dBuffer)
    % Store the LFPs for this data set. Downsample them to 1250 Hz, and
    % center them (individually) locally at zero.
    objLfps = getLfps(nd);
    objLfps = TimeSeries(downsample(objLfps.Data, 16), ...
                         downsample(objLfps.Time, 16));
    nFilterLength = 0.5 * sampleRate(nd);

    for i = 1 : 3
        vLfp = objLfps.Data(:, i);
        objLfps.Data(:, i) = vLfp - localmean(vLfp, nFilterLength);
    end

    % We also want to know where spikes happen and what the GUI should output.
    cellTrains = getSpikeTrains(nd);

    % Clear whatever was on the figure.
    clf();

    % Retrive the event times and the time window to use when displaying the
    % event.
    vEventWindow = getWindow(evt);
    vTimeWindow = vEventWindow + dBuffer * [-1, 1];

    % Plot the main ripple events over the LFP-triple.
    axEvent = subplot(2, 1, 1);
    objLocalLfps = subseries(objLfps, vTimeWindow(1), vTimeWindow(2));
    plot(axEvent, objLocalLfps.Time, objLocalLfps.Data);

    % Set plot niceties.
    set(axEvent, 'Layer', 'top');
    legend('Main', 'Low', 'High');
    ylabel('');
    xlabel(axEvent, 'Time (seconds)');
    xlim(vTimeWindow);
    set(axEvent, 'Color', [1, 1, 1]);

    PlotIntervals(vEventWindow, 'rectangles');

    axSpikes = subplot(2, 1, 2);
    evtWindow = getEvent(nd, vTimeWindow);
    plot(evtWindow, 'vOrdering', orderCells(evtWindow));
    set(axEvent, 'Layer', 'top');
    set(axEvent, 'Color', [1, 1, 1]);
    PlotIntervals(vEventWindow, 'rectangles');
end
