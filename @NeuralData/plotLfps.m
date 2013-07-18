function plotLfps(this, varargin)
    timeWindow = [0, length(mainLfp(this)) - 1];
    units = 'indices';
    parseNamedParams();

    if strcmp(units, 'indices')
        unitsToIndices = 1;
    elseif strcmp(units, 'milliseconds')
        unitsToIndices = sampleRate(this) / 1000;
    elseif strcmp(units, 'seconds')
        unitsToIndices = sampleRate(this);
    else
        error('Invalid units');
    end

    idxs = round(timeWindow(1) * unitsToIndices : timeWindow(2) * unitsToIndices) + 1;
    t = (idxs - 1) / unitsToIndices;

    low = lowLfp(this, idxs);
    main = mainLfp(this, idxs);
    high = highLfp(this, idxs);

    figure();
    plot(t, low, 'b', ...
         t, main, 'r', ...
         t, high, 'g');

    title('Local Field Potentials');
    legend('Low', 'Main', 'High');
    xlabel(['Time (' units ')']);
    xlim(timeWindow);
end