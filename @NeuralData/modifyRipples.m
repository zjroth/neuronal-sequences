function modifyRipples(this, varargin)
    removeInterneurons = false;
    restrictToActive = false;
    parseNamedParams();

    lfpTriple = [lowLfp(this), mainLfp(this), highLfp(this)];
    lfpTriple = bsxfun(@minus, lfpTriple, mean(lfpTriple, 1));

    timeline = (0 : size(lfpTriple, 1) - 1) / rawSampleRate(this);
    lfpTripleTs = TimeSeries(lfpTriple, timeline);

    strRippleFile = [this.baseFolder filesep 'computed' filesep 'ripples.mat'];

    % Create a figure
    fig = figure();

    % Set the callback function that is used when a key is pressed.
    set(fig, 'KeyReleaseFcn', @handleKeyPress);

    % Create a button to export the figure order.
    btnExport = uicontrol(fig, ...
        'Style', 'pushbutton', ...
        'String', 'Export Ripples', ...
        'Position', [10 10 120 40]);
    set(btnExport, 'Callback', @exportRipples);

    % Set the initial plot order, and display the first figure.
    nRipples = getRippleCount(this);
    nCurrRipple = 1;
    cellOrderings = { (1 : length(getSpikeTrains(this))) };
    plotRipple(this, nCurrRipple, 'cellOrderings', cellOrderings);

    function handleKeyPress(hObject, eventdata)
        if strcmp(eventdata.Key, 'rightarrow') || strcmp(eventdata.Key, 'space')
            nCurrRipple = min(nCurrRipple + 1, getRippleCount(this));
        elseif strcmp(eventdata.Key, 'leftarrow') || strcmp(eventdata.Key, 'backspace')
            nCurrRipple = max(nCurrRipple - 1, 1);
        elseif strcmp(eventdata.Key, 'delete')
            removeRipple(this, nCurrRipple);
            nCurrRipple = max(1, min(getRippleCount(this), nCurrRipple));
        elseif strcmp(eventdata.Key, 'd')
            this.current.ripples = this.current.ripples( ...
                [(1 : nCurrRipple), (nCurrRipple : end)], :);
        elseif strcmp(eventdata.Key, 's')
            mtxRipples = getRipples(this);
            save(strRippleFile, 'nCurrRipple', 'mtxRipples');
        end

        plotRipple(this, nCurrRipple, 'cellOrderings', cellOrderings);
    end

    function exportRipples(hObject, eventdata)
        assignin('base', 'mtxRipples', mtxRipples);
    end
end