function hndl = plotRipples(varargin)
    % Parameters
    % - ripples1
    % - ripples2
    % - lfpTriple
    % - sharpWave
    % - minSharpWavePeak
    % - minSharpWave
    % - rippleSpect
    % - rippleFreqs
    % - rippleWave
    % - thetaSpect
    % - thetaFreqs
    % - thetaWave
    % - maxThetaWave
    % - minRippleWavePeak
    % - minRippleWave
    % - eventsToPlot
    title1 = '';
    title2 = '';
    eventsToPlot = 'all';

    parseNamedParams();

    if strcmp(eventsToPlot, 'all')
        eventsToPlot = (1 : size(ripples1, 1));
    end

    % Loop through Eva's events, saving each figure along the way.
    for i = eventsToPlot
        % Create a full-screen figure.
        hdl = figure();
        screen_size = get(0, 'ScreenSize');
        set(hdl, 'Position', [0 0 screen_size(3) screen_size(4)]);

        % Get the x-limits.
        rippleStart = ripples1(i, 1);
        ripplePeak = ripples1(i, 2);
        rippleEnd = ripples1(i, 3);
        x_min = rippleStart - 0.1;
        x_max = rippleEnd + 0.1;

        % Plot the main ripple events over the LFP-triple.
        h(1) = subplot(7, 1, 1);
        plot(subseries(lfpTriple, x_min, x_max));

        for j = 1 : size(ripples1, 1)
          if (ripples1(j, 1) > x_min || ripples1(j, 3) < x_max)
            showRipple(ripples1(j, 1), ripples1(j, 2), ripples1(j, 3), [0.5, 0.5, 0.5]);
          end
        end

        showRipple(rippleStart, ripplePeak, rippleEnd, [0.5, 0.5, 0.5]);
        title(title1);
        xlim([x_min, x_max]);
        ylim([-2000, 2000]);

        % Plot the secondary ripple events over the LFP-triple.
        h(2) = subplot(7, 1, 2);
        plot(subseries(lfpTriple, x_min, x_max));
        title(title2);
        xlim([x_min, x_max]);

        for j = 1 : size(ripples2, 1)
          if (ripples2(j, 1) > x_min && ripples2(j, 3) < x_max)
            showRipple(ripples2(j, 1), ripples2(j, 2), ripples2(j, 3), [0.5, 0.5, 0.5]);
          end
        end

        % Plot the sharp-wave signal with the corresponding thresholds.
        h(3) = subplot(7, 1, 3);
        localSharpWave = subseries(sharpWave, x_min, x_max);
        plot(localSharpWave);
        hline(gca, minSharpWavePeak, [1, 0, 0]);
        hline(gca, minSharpWave, [1, 0, 0]);
        title('Sharp-Wave Signal');

        % Plot the sharp-wave first derivative signal with the corresponding threshold.
        h(4) = subplot(7, 1, 4);
        localFirstDerivative = subseries(firstDerivative, x_min, x_max);
        plot(localFirstDerivative);
        hline(gca, minFirstDerivative, [1, 0, 0]);
        title('Sharp-Wave First Derivative');

        % Plot the sharp-wave second derivative signal with the corresponding threshold.
        h(5) = subplot(7, 1, 5);
        localSecondDerivative = subseries(secondDerivative, x_min, x_max);
        plot(localSecondDerivative);
        hline(gca, minSecondDerivative, [1, 0, 0]);
        title('Sharp-Wave Second Derivative');

        % Plot the ripple-band spectrogram.
        h(6) = subplot(7, 1, 6);
        localRippleSpect = subseries(rippleSpect, x_min, x_max);
        PlotColorMap(localRippleSpect.Data', 'x', localRippleSpect.Time, 'y', rippleFreqs);
        title('Spectrogram in Ripple Frequency Range');

        % Plot the ripple-wave signal with the corresponding thresholds.
        h(7) = subplot(7, 1, 7);
        localRippleWave = subseries(rippleWave, x_min, x_max);
        plot(localRippleWave);
        hline(gca, minRippleWavePeak, [1, 0, 0]);
        hline(gca, minRippleWave, [1, 0, 0]);
        title('Ripple-Wave Signal');

        linkaxes(h, 'x');
        linkprop([h(1), h(2)], 'YLim');
    end
end

function showRipple(rippleStart, ripplePeak, rippleEnd, rippleColor, rippleOpacity)
    if nargin < 5
       rippleOpacity = 0.3;
    end
  ylims = get(gca, 'YLim');
  y_min = ylims(1);
  y_max = ylims(2);
  hold('on');
  vline(gca, ripplePeak, [1 0 0]);
  fill([rippleStart rippleStart rippleEnd rippleEnd], ...
       [y_min y_max y_max y_min], ...
       rippleColor, ...
       'FaceAlpha', rippleOpacity);
  hold('off');
end

function ts_new = subseries(ts, mn, mx)
    idxs = (ts.Time > mn & ts.Time < mx);
    ts_new = getsamples(ts, idxs);
end
