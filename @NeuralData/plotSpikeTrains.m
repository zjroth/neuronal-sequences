% plotSpikeTrains(this, vTimeWindow, varargin)
function plotSpikeTrains(this, vTimeWindow, varargin)
    % Set some defaults for this function, and the overwrite those values with
    % any provided optional parameters.
    strPlotTitle = 'Spike Raster Plot';
    mtxColors = lines();
    bRemoveInterneurons = false;

    parseNamedParams();

    % Store the start/end of the ripple window, and store the number of colors
    % that we have to work with.
    dMinTime = vTimeWindow(1);
    dMaxTime = vTimeWindow(2);
    nColors = size(mtxColors, 1);

    % Retrieve the trains to be plotted.
    cellTrains = getSpikeTrains(this);

    % Interneurons are distracting. Remove them.
    if bRemoveInterneurons && isfield(this.parameters, 'interneurons')
        cellTrains(this.parameters.interneurons) = {[]};
    end

    % If a custom ordering wasn't provided, just use the default order.
    if ~exist('vNeuronOrder', 'var')
        vNeuronOrder = (1 : length(cellTrains));
    end

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
        plot(vTrain, j * ones(size(vTrain)), '.', 'Color', spikeColor);
    end

    % Now that everything has been plotted, tidy up.
    hold('off');
    title(strPlotTitle);
    ylabel('Neuron');
    xlabel('Time (seconds)');
    xlim([dMinTime, dMaxTime]);
    ylim([0, length(vNeuronOrder) + 1]);
end
