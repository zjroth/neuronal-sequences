clear
clear NeuralData
clc

tic;
neuralData = NeuralData('~/data/Eva-new-maze-2013/A543-20120422-01/A543-20120422-01');
neuralData.loadChannels(35, 46, 34);

load('~/data/pastalkova/A543-20120422-01/A543-20120422-01_DataStructure_mazeSection4_TypeMaze1_FieldSeqCompPrePost_125msP_50msH_L.mat');
leftNeurons = fieldSeqCompStructLe.indNeuronOrdered1st;
load('~/data/pastalkova/A543-20120422-01/A543-20120422-01_DataStructure_mazeSection5_TypeMaze1_FieldSeqCompPrePost_125msP_50msH_L.mat');
rightNeurons = fieldSeqCompStructRi.indNeuronOrdered1st;

% neuralData = NeuralData('~/data/pastalkova/A543-20120412-01/A543-20120412-01');
% neuralData.loadChannels(39, 105, 77);
toc;

%%
tic;
sw = getSharpWave(neuralData);
[rw, rwt] = getRippleWave(neuralData);

toc;

%%
tic;
ripples = neuralData.detectRipples(sw, rw, rwt, ...
    'minSharpWavePeak', 2, ...
    'minSharpWave', 1.0, ...
    ...
    'minRippleWavePeak', 0, ...
    'minRippleWave', -Inf, ...
    ...
    'minFirstDerivative', 2.75, ...
    'minSecondDerivative', Inf);
% [s, t, f] = neuralData.getRippleSpectrogram('sampleRate', 1);
toc;

%%
lfpMain = neuralData.mainLfp();
lfpLow = neuralData.lowLfp();
lfpHigh = neuralData.highLfp();

timeline = (0 : length(lfpMain) - 1) / rawSampleRate(neuralData);

lfpTriple   = [lfpLow - mean(lfpLow), lfpHigh - mean(lfpHigh), lfpMain - mean(lfpMain)];
lfpTripleTs = timeseries(lfpTriple, timeline);

clear plotRipples
plotRipples(ripples, lfpTripleTs, neuralData, ...
    'events', 1 : size(ripples, 1), ...
    ...'neurons', [leftNeurons, rightNeurons], ...
    'ripplePadding', 0.05)





