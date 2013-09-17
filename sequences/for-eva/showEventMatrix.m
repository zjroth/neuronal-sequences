% showEventMatrix()
function showEventMatrix(dThresh)
    if nargin < 1 || isempty(dThresh)
        dThresh = 0.025;
    end

    % Load all of the data.
    load('data.mat', 'cellSpikeTrains', 'cellSequences', ...
         'mtxRipples', 'nPre', 'nMusc', 'nPost', 'mtxNeuronActivity', ...
         'mtxPNaught', 'mtxRho');

    mtxNumCoactive = mtxNeuronActivity * mtxNeuronActivity';

    % A rho value is determined to be significant if it is greater (in
    % absolute value) than the corresponding rho-naught value and if the
    % sequences share an appropriate number of active neurons.
    nMinCoActive = 0;
    mtxSignificant = triu((mtxPNaught <= dThresh) .* (mtxNumCoactive >= nMinCoActive), 1);
    mtxSignificant = mtxPNaught .* mtxSignificant;
    mtxSignificant = mtxSignificant + mtxSignificant.';

    % Use the matrix of "significant" rho values to build a graph, and
    % determine the graph's sparsity.
    spmxAdj = spones(mtxSignificant);

    vGroupSizes = [nPre, nMusc, nPost];

    % The number of elements is the number of rows in the correlation matrix.
    nElts = size(mtxPNaught, 1);
    assert(sum(vGroupSizes) == nElts);

    % Sort the elements using the default order.
    vEltOrder = (1 : nElts);

    mtxImage = triu(mtxSignificant(vEltOrder, vEltOrder), 1);

    % Create the figure.
    hdlFigure = figure();

    whiteImage(log10(mtxImage) .* sign(mtxRho), logical(mtxImage), 0.5, -1);
    set(gca, 'YDir', 'normal')

    % Label the plot and set x- and y-limits.
    set(gca,'XTick', [nPre / 2; nPre + nMusc / 2; nPre + nMusc + nPost / 2])
    set(gca,'XTickLabel', {'Pre-muscimol'; 'Muscimol'; 'Post-muscimol'})
    set(gca,'YTick', [nPre / 2; nPre + nMusc / 2; nPre + nMusc + nPost / 2])
    set(gca,'YTickLabel', {'Pre-muscimol'; 'Muscimol'; 'Post-muscimol'})
    xlabel('Sequence Events');
    ylabel('Sequence Events');
    title(['$\log_{10}(p_0) \times \textrm{sign}(\rho)$'], ...
        'Interpreter', 'latex');
    xlim([0, nElts]);
    ylim([0, nElts]);

    % Show lines indicating the separation between pre/musc/post sequences
    % and a line showing the diagonal.
    vGroupSplitIndices = cumsum(vGroupSizes);
    for i = 1 : length(vGroupSplitIndices)
        vline(vGroupSplitIndices(i));
        hline(vGroupSplitIndices(i));
    end

    line([0, nElts], [0, nElts]);

    % Create a button to export the figure order.
    btnDisplay = uicontrol(hdlFigure, ...
        'Style', 'pushbutton', ...
        'String', 'View sequences', ...
        'Position', [10 10 120 40]);
    set(btnDisplay, 'Callback', @displaySequences);

    % Ensure that the figure has the normal toolbar (for zooming and whatnot).
    set(hdlFigure, 'toolbar', 'figure')

    % This function is called when the button is clicked.
    function displaySequences(hObject, eventdata)
        % Prompt the user to click on a pixel in the image, which will return
        % the corresponding x and y values of the point clicked on (not of the
        % actual integer-valued pixel).
        [x, y] = ginput(1);

        % To get the corresponding sequences, first round the x and y values to
        % the nearest integer (since a pixel is centered on the point that it
        % corresponds to). Now, since the sequences have been sorted (to
        % group them), find the inverse permutation of the current ordering.
        nSeqX = vEltOrder(round(x));
        nSeqY = vEltOrder(round(y));

        % Retrieve the ideal sort order for sequence x, and retrieve the neurons
        % that are active in sequence y. The neuron order is the order given by
        % the ideal order for sequence x with the restriction that all neurons
        % must also belong to sequence y.
        vOrderForX = sortNeuronsForRipple(nSeqX);
        vOrderForY = sortNeuronsForRipple(nSeqY);
        vInX = find(mtxNeuronActivity(nSeqX, :));
        vInY = find(mtxNeuronActivity(nSeqY, :));
        vNeuronOrderX = intersect(vOrderForX, vInY, 'stable');
        vNeuronOrderY = intersect(vOrderForY, vInX, 'stable');

        % Plot the sequences with the above-found sorting order.
        figure();
        set(gcf, 'name', ['rho value: ' num2str(mtxRho(nSeqY, nSeqX)) '; ' ...
                          'p_0 value: ' num2str(mtxPNaught(nSeqY, nSeqX))]);

        subplot(2, 2, 1);
        plotSpikeTrains(nSeqX, vNeuronOrderX);
        title(['Sequence ' num2str(nSeqX) ' (ideal ordering)']);

        subplot(2, 2, 2);
        plotSpikeTrains(nSeqX, vNeuronOrderY);
        title(['Sequence ' num2str(nSeqX) ' (ideal ordering for sequence ' num2str(nSeqY) ')']);

        subplot(2, 2, 3);
        plotSpikeTrains(nSeqY, vNeuronOrderX);
        title(['Sequence ' num2str(nSeqY) ' (ideal ordering for sequence ' num2str(nSeqX) ')']);

        subplot(2, 2, 4);
        plotSpikeTrains(nSeqY, vNeuronOrderY);
        title(['Sequence ' num2str(nSeqY) ' (ideal ordering)']);
    end

    % plotSpikeTrains(nRipple, varargin)
    function vOrder = sortNeuronsForRipple(nRipple)
        vRipple = mtxRipples(nRipple, :);
        cellTrains = getSpikeTrains(nRipple);
        nNeurons = length(cellTrains);
        vCentersOfMass = zeros(nNeurons, 1);

        for j = 1 : nNeurons
            vTrain = cellTrains{j};
            vTrain = vTrain(vRipple(1) <= vTrain & vTrain <= vRipple(3));
            vCentersOfMass(j) = mean(vTrain);
        end

        [~, vOrder] = sort(vCentersOfMass);

        vOrder = vOrder(1 : nnz(~isnan(vCentersOfMass)));
    end

    function cellTrains = getSpikeTrains(nRipple)
        if nRipple <= nPre
            cellTrains = cellSpikeTrains(1 : 126);
        elseif nRipple <= nPre + nMusc
            cellTrains = cellSpikeTrains(127 : 252);
        else
            cellTrains = cellSpikeTrains(253 : 378);
        end
    end

    % plotSpikeTrains(nRipple, varargin)
    function plotSpikeTrains(nRipple, vNeuronOrder)
        mtxColors = lines();

        vRipple = mtxRipples(nRipple, :);
        cellTrains = getSpikeTrains(nRipple);

        % Store the start/end of the ripple window, and store the number of colors
        % that we have to work with.
        dMinTime = vRipple(1);
        dMaxTime = vRipple(3);
        nColors = size(mtxColors, 1);

        % Since each train will be plotted individually, we need to tell matlab not
        % to overwrite what has already been plotted.
        %set(gca, 'Layer', 'top');
        hold('on');

        % For each neuron's spike train, plot that spike train along a horizontal
        % line.
        for j = 1 : length(vNeuronOrder)
            % Extract the current neuron number.
            nCurrNeuron = vNeuronOrder(j);

            % Extract the portion of the current train that lives in the provided
            % time window.
            vTrain = cellTrains{nCurrNeuron};
            vTrain = vTrain(dMinTime <= vTrain & vTrain <= dMaxTime);

            % The color of this spike train is determined by the actual neuron
            % number, but the height of the plotted spike train is determined by the
            % index of the current neuron in the ordering.
            spikeColor = mtxColors(mod(nCurrNeuron, nColors) + 1, :);
            plot(vTrain, j * ones(size(vTrain)), '.', 'Color', spikeColor, ...
                 'MarkerSize', 10);
        end

        % Now that everything has been plotted, tidy up.
        hold('off');
        %ylabel('Neuron');
        xlabel('Time (seconds)');
        xlim([dMinTime, dMaxTime]);
        ylim([0, length(vNeuronOrder) + 1]);
    end
end

function [imagemtx,cBar,clim] = whiteImage(A,mask,thresh,fig,clim,colors);
    % function [imagemtx,cBar,clim] = whiteImage(A,mask,thresh,fig,clim,colors);
    %
    % A = matrix whose image you want to code in color
    % fig = figure in which to plot image (optional)
    % fig = 0 is default, and means no plot is made
    % fig = -1 plots w/o starting a new figure (allows to use as subplot)
    %
    % mask = matrix of same size as A, with values which determine whether
    %     entries of A are colored or masked (made white)
    % thresh = threshold below which A entries are masked
    %     i.e. if mask(i,j) < thresh, then A(i,j) will be white
    % clim = color limits (clip colors beyond these values)
    % colors = colormap (default is matlab default: jet(64))
    %     number of rows = number of colors, columns are rgb values
    % imagemtx = 3-d matrix of rgb values for each entry of A
    % cBar = corresponding colorbar (use SideBar(cBar) in figure)
    %
    % plot result via: image(imagemtx); SideBar(cBar);

    if (nargin < 3 || isempty(thresh))
        thresh = 0;
    end

    if (nargin < 2 || isempty(mask))
        mask = ones(size(A));
    end

    % mask infinite of NaN values as well
    mask = mask .* isfinite(A);  % assumes thresh > 0!
    idx = (mask >= thresh);  % colored values
    widx = (mask < thresh);  % white values

    if (nargin < 6 || isempty(colors))
        colors = flipud(jet(64));
        % note that colors(40,:) = [1 1 0] is yellow
    end

    if (nargin < 5 || isempty(clim))
        clim = [min(min(A(idx))), max(max(A(idx)))];

        if isempty(clim)
            clim = [0, 1];
        elseif clim(2) == clim(1)
            clim(2) = clim(1) + 1;
        end
    end

    if (nargin < 4 || isempty(fig))
        fig = 0;
    end

    ncolors = size(colors, 1);

    % normalize matrix A -- clip to make sure all values b/w 0 and 1
    normalA = (A - clim(1)) / diff(clim);
    normalA(normalA < 0) = 0;
    normalA(normalA > 1) = 1;
    normalA(widx) = 0;

    % colorA has color number (from 1 to ncolors) in each matrix entry
    colorA = ceil(normalA * ncolors);
    colorA(colorA == 0) = 1;             % make sure lowest color index is 1

    % make imagemtx(row,col,rgb)
    imagemtx = reshape(colors(colorA, :), [size(A), 3]);

    % white out all values obtained below threshold of data points
    imagemtx(repmat(widx, [1, 1, 3])) = 1;

    % make colorbar
    for i = 1:3
        cBar(:,:,i) = colors(:,i);
    end

    if fig ~=0
        if fig ~= -1
            figure(fig);
            set(gcf, 'DefaultAxesPosition', [0.05,0.04,.92,.90]);
        end

        image(imagemtx);
        sideBar(cBar,clim);
    end
end

% function ax = sideBar(cBar,zlim,h);
function ax = sideBar(cBar,zlim,h);
    % set values for which plot to add SideBar to (default: gca)
    if nargin < 3;
        h = gca;
        hfig = gcf;
    else
        hfig = get(h,'parent');
    end;

    if nargin < 2;
        zlim = [0 1];
    end;

    % legend('RestoreSize',h);  % restore axes to pre-legend size
    units = get(h,'units');
    set(h,'units','normalized');
    pos = get(h,'Position');
    stripe = 0.075;
    edge = 0.02;
    space = 0.05;
    set(h,'Position',[pos(1) pos(2) pos(3)*(1-stripe-edge-space) pos(4)]);
    % legend('RecordSize',h);  %set this as the new legend fullsize

    rect = [pos(1)+(1-stripe-edge)*pos(3) pos(2) stripe*pos(3) pos(4)];
    ax = axes('position',rect);
    set(h,'units',units);

    axes(ax);

    % most annoying bit is colorbar
    image(0,zlim(1)+(0:.01:1)*(zlim(2)-zlim(1)), cBar);
    set(gca, 'ydir', 'normal');
    set(gca, 'xtick', []);
    set(gca, 'yaxislocation', 'right');
    axes(h);
end

function vline(x, varargin)
    axesHandle = gca;
    color = [0, 0, 1];
    parseNamedParams();

    yLimits = get(axesHandle, 'YLim');
    line([x, x], yLimits, 'Color', color, 'Parent', axesHandle);
end

function hline(y, varargin)
    axesHandle = gca;
    color = [0, 0, 1];
    parseNamedParams();

    xLimits = get(axesHandle, 'XLim');
    line(xLimits, [y, y], 'Color', color, 'Parent', axesHandle);
end

function parseNamedParams(validNames)
    % Our list of parameters is `varargin` from the workspace of the
    % function that invoked this function.
    paramList = evalin('caller', 'varargin');

    % The number of named parameters represented by the parameter list.
    nParams = length(paramList) / 2;

    % By default, we will assume that all parameter names are valid.
    if nargin() == 0
        validNames = 'all';
    end

    % Create a function to determine whether or not a name is in the allowed
    % list of names.
    function valid = isAllowedName(name)
        if iscell(validNames)
            valid = any(strcmp(name, validNames));
        elseif ischar(validNames)
            valid = strcmp(validNames, 'all');
        else
            valid = false;
        end
    end

    % Loop through the named parameters.
    for i = 1 : nParams
        % Retrieve the name of the current parameter and its value.
        idx = 2 * i - 1;
        name = paramList{idx};
        val = paramList{idx + 1};

        % Complain if the parameter name is not a valid matlab variable
        % name.
        if isvarname(name)
            % Complain if the parameter name is not allowed by the caller
            % function.
            if isAllowedName(name)
                % If we've made it this far, then we want to assign the
                % provided value for the parameter name in the workspace
                % of the function that invoked this function.
                assignin('caller', name, val);
            else
                error(['parseNamedParams: invalid named parameter: ' name]);
            end
        else
            error(['parseNamedParams: invalid parameter name: ' name]);
        end
    end
end