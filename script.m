cd ~/projects/ripple-detector/
script_init_workspace

%% Load data and compute the ripple- and sharp-wave.
clear
clear loadRatData
clear NeuralData
clc

tic;
neuralData = loadRatData('A543', 2, 'muscimol');
toc;

tic;
sw = getSharpWave(neuralData);
rw = getRippleWave(neuralData);
toc;

lfpTriple = [neuralData.lowLfp(), neuralData.mainLfp(), neuralData.highLfp()];
lfpTriple = bsxfun(@minus, lfpTriple, mean(lfpTriple, 1));

timeline = (0 : size(lfpTriple, 1) - 1) / rawSampleRate(neuralData);
lfpTripleTs = timeseries(lfpTriple, timeline);

%% Find the ripple events and
tic;
ripples = neuralData.detectRipples( ...
    sw, rw.Data, rwt.Time,                    ...
    'minSharpWavePeak'    , 2,      ...
    'minSharpWave'        , 1.0,    ...
                                    ...
    'minRippleWavePeak'   , 0,      ...
    'minRippleWave'       , -Inf,   ...
                                    ...
    'minFirstDerivative'  , 2.75,   ...
    'minSecondDerivative' , Inf);
toc;

disp(['Number of detected ripples: ' num2str(size(ripples, 1))]);

%% Parameters for plotting
currRipple = 56;

% Set the order of the neurons
neuronSet = (1 : length(neuralData.getSpikeTrains()));
% neuronSet = unique(neuralData.parameters.placeCellOrdering, 'stable');

% % Set the order of the ripples
% rippleOrder = (1 : size(ripples, 1));
% rippleOrder = neuralData.getNearestRipples(currRipple);

% Sort the ripples by overlap with the neuron set.
mtxSpikesPerRipple = neuralData.getRippleSpikeMatrix();
mtxSpikesPerRipple = mtxSpikesPerRipple(unique(neuronSet), :);
[vals, rippleOrder] = sort(sum(mtxSpikesPerRipple > 0, 1), 'descend');
rippleOrder = rippleOrder(vals > 10);

% Sort the ripples by...
clear getNeuronOrderings;
getNeuronOrderings;

keys = neuronOrderings.optimal.pre.keys;
vals = neuronOrderings.optimal.pre.values;
rippleOrder = zeros(length(neuronOrderings.optimal.pre), size(ripples, 1));
cellOrderings = cell(length(neuronOrderings.optimal.pre), 1);

for i = 1 : length(neuronOrderings.optimal.pre)
    rippleOrder(i, :) = (sum(mtxSpikesPerRipple(vals{i}, :) > 0) > 15);
    cellOrderings{i} = { ...
        vals{i}, ['Pre-muscimol ripple ' num2str(keys{i}) ' ordering'] ...
    };
end

rippleOrder = find(any(rippleOrder, 1));

% tmp = cellfun(@(c) find(sum(mtxSpikesPerRipple(c{2}, :) > 0) > 15), ...
%     neuronOrderings, ...
%     'UniformOutput', false);
% rippleOrder = rippleOrder(unique([tmp{:}]));
%
% tmp = cellfun(@(c) {c{2}, ['Pre-muscimol ripple ' num2str(c{1}) ' ordering']}, ...
%     neuronOrderings, ...
%     'UniformOutput', false);
% cellOrderings = @(nRipple) tmp;

activityPattern = neuralData.getRippleActivity(currRipple);
activityPattern = activityPattern(neuronSet);

%% Plot
rippleOrder = ...
    [355, 496, 579, 227, 230, 109, 285, 231, 300, 327, 400, 221, 286, ...
    305, 328, 425, 111, 60];
rippleOrder = sort(rippleOrder);
nFigures = length(rippleOrder);

clear plotRipple
navigateFigures(nFigures, @(nFig) ...
    plotRipple(rippleOrder(nFig), lfpTripleTs, neuralData, ...
        ... 'neuronSet', neuronSet, ...
        ...'activityPattern', activityPattern, ...
        'cellOrderings', cellOrderings, ...
        'removeInterneurons', true, ...
        'ripplePadding', 0.06) ...
);

%%

clear plotRipple
navigateFigures(size(ripples, 1), @(nFig) ...
    plotRipple(nFig, lfpTripleTs, neuralData, ...
        ... 'neuronSet', neuronSet, ...
        ... 'activityPattern', activityPattern, ...
        'cellOrderings', {neuronSet}, ...
        'removeInterneurons', true, ...
        'ripplePadding', 0.06), ...
    true ...
);
