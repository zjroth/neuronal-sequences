% showEventMatrix(mtxCorrVals, mtxPVals, vGroupSizes, fcnOnClick)
function showEventMatrix(mtxCorrVals, mtxPVals, vGroupSizes, fcnOnClick)
    % The number of elements is the number of rows in the correlation matrix.
    nElts = size(mtxCorrVals, 1);
    assert(sum(vGroupSizes) == nElts);

    % Sort the elements by group and then by component size.
    vEltOrder = (1 : nElts);

    % To construct the bubble plot, we need the locations of the rho values
    % that are above the threshold (in absolute value) in addition to the
    % actual values.
    mtxImage = triu(mtxPVals(vEltOrder, vEltOrder), 1);

    % Create the figure.
    hdlFigure = figure();

    whiteImage(log10(mtxImage) .* sign(mtxCorrVals), logical(mtxImage), 0.5, -1);
    set(gca, 'YDir', 'normal')

    % Label the plot and set x- and y-limits.
    xlabel('Sequence Events');
    ylabel('Sequence Events');

    % Show lines indicating the separation between pre/musc/post sequences
    % and a line showing the diagonal.
    vGroupSplitIndices = cumsum(vGroupSizes);
    for i = 1 : length(vGroupSplitIndices)
        vline(vGroupSplitIndices(i));
        hline(vGroupSplitIndices(i));
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
        nEventX = vEltOrder(round(x));
        nEventY = vEltOrder(round(y));

        fcnOnClick(nEventX, nEventY);
    end
end

function vSequenceOrder = sortSequence(vComponentSize, vComponentIndex, vGroupSizes)
    % Determine the order in which to display the sequences.  The sequences
    % are grouped first by pre/musc/post and then sorted by the size of the
    % component to which the sequence belongs in the threshold graph.

    % Retrieve the component numbers sorted by descending size of the
    % corresponding component.
    [vSortedComponentSizes, vOrderedBySize] = sort(vComponentSize, 'descend');
    [~, vOrderedBySize] = sort(vOrderedBySize);

    % Now that we have a list of the components sorted by size, we can sort the
    % vector containing the indices of the components that each vertex belongs
    % to by the size of the corresponding component. To do this, build a vector
    % containing...
    vTmp = vOrderedBySize(vComponentIndex);

    vGroupSplitIndices = [0, cumsum(vGroupSizes)];
    vSequenceOrder = [];

    for i = 1 : length(vGroupSplitIndices) - 1
        [~, vOrder] = sort(vTmp(vGroupSplitIndices(i) + 1 : vGroupSplitIndices(i + 1)));
        vSequenceOrder = [vSequenceOrder; vOrder + vGroupSplitIndices(i)];
    end
end
