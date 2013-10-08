cd ~/projects/ripple-detector/
script_init_workspace

%% Find the ripple events and
tic;
ripples = neuralData.detectRipples( ...
    'minSharpWavePeak'    , 2,   ...
    'minSharpWave'        , 1.0,    ...
                                    ...
    'minRippleWavePeak'   , 2,      ...
    'minRippleWave'       , -Inf,   ...
                                    ...
    'minFirstDerivative'  , 2.75,   ...
    'minSecondDerivative' , Inf);
toc;

disp(['Number of detected ripples: ' num2str(size(ripples, 1))]);

%% Parameters for plotting
currRipple = 1;

% Set the order of the neurons
neuronSet = (1 : length(neuralData.getSpikeTrains()));

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

activityPattern = neuralData.getRippleActivity(currRipple);
activityPattern = activityPattern(neuronSet);

%% Plot

clear NeuralData.plotRipple
rippleOrder = [487, 441] - 184;
navigateFigures(getRippleCount(objRatData.musc), @(nFig) ...
    objRatData.musc.plotRipple(rippleOrder(nFig), ...
        ... 'neuronSet', neuronSet, ...
        ... 'activityPattern', activityPattern, ...
        'cellOrderings', {1:126}, ...
        'removeInterneurons', true, ...
        'ripplePadding', 0.06), ...
    true ...
);
