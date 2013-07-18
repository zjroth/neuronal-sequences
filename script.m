cd projects/ripple-detector/
script_init_workspace

%%
clear
clear NeuralData
clc

tic;
neuralData = loadRatData('A543', 2, 'muscimol');
toc;

%%
tic;
sw = getSharpWave(neuralData);
[rw, rwt] = getRippleWave(neuralData);
toc;

%%
tic;
ripples = neuralData.detectRipples( ...
    sw, rw, rwt,                    ...
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

%%
lfpTriple = [neuralData.lowLfp(), neuralData.mainLfp(), neuralData.highLfp()];
lfpTriple = bsxfun(@minus, lfpTriple, mean(lfpTriple, 1));

timeline = (0 : size(lfpTriple, 1) - 1) / rawSampleRate(neuralData);
lfpTripleTs = timeseries(lfpTriple, timeline);

%%
currRipple = 425;
order = neuralData.getNearestRipples(currRipple);

clear plotRipple

% 425, 287, 45, 105, 117

% drugged, minSecondDerivative default:
% 296, 325, 77, 83, 137, 157, 324, 61, 76, 275, 176, 187, 204, 222, 245,
% 275, 395

navigateFigures(@(nFig) ...
    plotRipple(order(nFig), lfpTripleTs, neuralData, ...
        'masterRipple', currRipple, ...
        ... 'events', order, ...
        ... 'interneurons', interneurons, ...
        'ripplePadding', 0.06) ...
);
