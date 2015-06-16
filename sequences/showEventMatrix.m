% USAGE:
%    showEventMatrix(mtxCorrVals, mtxP, dThresh, vGroupSizes, fcnOnClick)
%
% DESCRIPTION:
%    .
%
% ARGUMENTS:
%    mtxP
%       A matrix of p values to display
%    cellSpikeSeries
%       A cell array of cell arrays of `SpikeSeries` objects
%
% NAMED PARAMETERS:
%    dMaxP (default: 0.05)
%       All p values greater than or equal to this are not shown
%    fcnOnClick (default: nothing)
%       A function that takes two parameters, the x and y values of the pixel
%       that is selected on a user's click
%    vGroupSizes (default: [])
%       This is ignored if `cellSpikeSeries` is a cell array of cell arrays
%    mtxColorMap (default: `flipud(jet(64))`)
%       A 3-column matrix of RGB colors to use as the color map
%    mtxSigns (default: all ones)
%       .
function showEventMatrix(mtxP, cellSpikeSeries, varargin)
    % Get set the default parameter values.
    dMaxP = 0.05;
    fcnOnClick = [];
    vGroupSizes = [];
    mtxColorMap = flipup(jet(64));
    mtxSigns = 1;
    parseNamedParams();

    % Ensure that the input matrix is square.
    assert(size(mtxP, 1) == size(mtxP, 2), ...
           'showEventMatix: the first input must be a square matrix.');

    % The number of elements is the number of rows in the correlation matrix.
    nElts = size(mtxP, 1);

    % Retrieve the size of the groups if they're specified as part of the
    % cell array of spikes.
    if strcmp(class(cellSpikeSeries{1}), 'cell')
        vGroupSizes = cellfun(@length, cellSpikeSeries);

        % Also flatten the list of spikes.  The result here is a cell array
        % of `SpikeSeries` objects.
        cellSpikeSeries = {cellfun(@(x) x{:}, cellSpikeSeries)};
    end

    % Retrieve the spike trains associated with this list of spikes.
    cellTrains = cellfun(@SpikeSeries.trains, cellSpikeSeries);

    % Ensure that the size of the groups is consistent with the size of the
    % input matrix.
    if ~isempty(vGroupSizes)
        assert(nElts == sum(vGroupSizes));
    end

    % Deem an entry significant if the corresponding p-value is small enough.
    mtxSignificant = triu(mtxP < dMaxP, 1);
    dMinNonzero = min(nonzeros(mtxP));
    mtxImage = log10(max(abs(mtxP), dMinNonzero / 2)) .* sign(mtxSigns);

    % Create the figure and display the image.
    hdlFigure = figure();
    whiteImage(mtxImage, mtxSignificant, 0.5, -1, [], mtxColorMap);
    set(gca, 'YDir', 'normal')

    % Label the plot and set x- and y-limits.
    xlabel('Events');
    ylabel('Events');

    % Show lines indicating the separation between pre/musc/post sequences
    % and a line showing the diagonal.
    if ~isempty(vGroupSizes)
        vGroupSplitIndices = cumsum(vGroupSizes);
        for i = 1 : length(vGroupSplitIndices)
            vline(vGroupSplitIndices(i) + 0.5);
            hline(vGroupSplitIndices(i) + 0.5);
        end
    end

    line([0, nElts], [0, nElts]);

    % Create a button to view a pair of spike trains.
    btnDisplay = uicontrol(hdlFigure, ...
                           'Style', 'pushbutton', ...
                           'String', 'View sequences', ...
                           'Position', [10 10 120 40]);
    set(btnDisplay, 'Callback', @selectPixelAndExecute);

    % Ensure that the figure has the normal toolbar (for zooming and whatnot).
    set(hdlFigure, 'toolbar', 'figure')

    % This function is called when the button is clicked.
    function selectPixelAndExecute(hObject, eventdata)
        % Prompt the user to click on a pixel in the image, which will return
        % the corresponding x and y values of the point clicked on (not of the
        % actual integer-valued pixel).
        [x, y] = ginput(1);

        % Round the x and y values to the nearest integers (since a pixel is
        % centered on the point that it corresponds to) before invoking the
        % corresponding function. Since the sequences have potentially been
        % sorted (to group them), use the element ordering to determine the
        % event that actually corresponds to the selected pixel.
        nEventX = round(x);
        nEventY = round(y);

        compareSpikeSeries(cellSpikeSeries{nEventX}, cellSpikeSeries{nEventY});
        set(gcf, 'name', ['P value: ' num2str(mtxP(nEventY, nEventX))]);
    end
end


% compareSpikeTrains(this, strCondX, vTimeWindowX, strCondY, vTimeWindowY)
function compareSpikeSeries(objSeriesX, objSeriesY)
    cellXTrains = cellTrainCollns{vCollnNums(nX)};
    cellYTrains = cellTrainCollns{vCollnNums(nY)};

    vTimeWindowX = mtxEvents(nX, :);
    vTimeWindowY = mtxEvents(nY, :);

    % Retrieve the ideal sort order for sequence x, and retrieve the neurons
    % that are active in sequence y. The neuron order is the order given by
    % the ideal order for sequence x with the restriction that all neurons
    % must also belong to sequence y.
    vOrderForX = sortNeuronsInWindow(cellXTrains, vTimeWindowX);
    vOrderForY = sortNeuronsInWindow(cellYTrains, vTimeWindowY);
    vInX = intersect(vOrderForX, vActiveNeurons);
    vInY = intersect(vOrderForY, vActiveNeurons);
    vNeuronOrderX = intersect(vOrderForX, vInY, 'stable');
    vNeuronOrderY = intersect(vOrderForY, vInX, 'stable');

    % Plot the sequences with the above-found sorting order.
    figure();

    subplot(2, 2, 1);
    plot(objSeriesX, ...
        vTimeWindowX, vNeuronOrderX, 'bRemoveInterneurons', true);
    title('Sequence 1 (ideal ordering)');

    subplot(2, 2, 2);
    plot(objSeriesX, ...
        vTimeWindowX, vNeuronOrderY, 'bRemoveInterneurons', true);
    title('Sequence 1 (ideal ordering for sequence 2)');

    subplot(2, 2, 3);
    plot(objSeriesY, ...
        vTimeWindowY, vNeuronOrderX, 'bRemoveInterneurons', true);
    title('Sequence 2 (ideal ordering for sequence 1)');

    subplot(2, 2, 4);
    plot(objSeriesY, ...
        vTimeWindowY, vNeuronOrderY, 'bRemoveInterneurons', true);
    title('Sequence 2 (ideal ordering)');
end
