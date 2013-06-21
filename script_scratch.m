script_init_workspace;

load('data/entire-spectrogram.mat');
load('data/computed-data-orig.mat', 'dat');

lfpLow = dat(:, 3);
lfpHigh = dat(:, 1);
clear('dat');

smth = @(v, r) conv(v, gaussfilt(2*r*sampleRate + 1), 'same');

%%
load data/entire-spectrogram-50ms-window.mat rplSpect rplTimes rplFreqs

spect50ms = zeros(size(rplSpect, 1), length(lfp));
spect50ms(:, round(rplTimes * sampleRate)) = rplSpect;

%%
spect50ms = scaleLfpSpectrogram(spect50ms, rplFreqs);

%%

sharpWave = computeSharpWave(lfpLow, lfpHigh, gaussfilt(2*0.011*sampleRate + 1));
smthSharpWave = smth(sharpWave, 0.011);

meanSpect = mean(spect, 1);
rippleWave = zeros(size(lfp)) + mean(mean(spect));
rippleWave(round(times * sampleRate)) = meanSpect;
smthRipple = smth(rippleWave, 0.011);

smthRipple250ms = smth(rippleWave250ms, 0.011);
smthRipple50ms = smthRipple;

thetaWave = zeros(size(lfp)) + mean(mean(thetaSpect));
thetaWave(round(thetaTimes * sampleRate)) = mean(thetaSpect, 1);
smthTheta = smth(thetaWave, 0.011);

return;

%%

lowband = 90;
highband = 180;
filtOrder = 500;
avgFiltOrder = 501;
firfiltb = fir1(filtOrder, [lowband/sampleRate*2,highband/sampleRate*2]);
avgfiltb = ones(avgFiltOrder,1)/avgFiltOrder;
rip = Filter0(firfiltb, lfp); % filtering
rip = rip.^2; % filtered * filtered >0
rip = zscore(rip);
fRip = smth(rip, 0.011);

%%

ripples = DetectRipples([lfpHigh, lfp, lfpLow],     ...
    'sharpWave'            , zscore(smthSharpWave), ...
    'minSharpWavePeak'     , 3,                     ...
    'minSharpWave'         , 1.5,                     ...
                                                    ...
    'rippleWave'           , zscore(smthRipple50ms),    ...
    'minRippleWavePeak'    , 1,                     ...
    'minRippleWave'        , -Inf,                     ...
                                                    ...
    'thetaWave'            , zscore(smthTheta),     ...
    'maxThetaDuringRipple' , 2                      ...
    );

spw = mtx2spw(ripples);

%%

plotRipples(                         ...
    uniqueRipples(spwOrig),          ...
    spw,                             ...
    [lfpHigh, lfp, lfpLow],          ...
    zscore(smthSharpWave),           ...
    spect50ms,          ...
    zscore(thetaWave),               ...
    46, ...1 : length(spwOrig.startT), ...
    rplFreqs, ...
    'title2', 'LFPs and Eva''s Events',     ...
    'title1', 'LFPs and My Events',     ...
    'title3', 'Sharp-wave Signal',     ...
    'title4', 'Ripple Wave (spect. method)',     ...
    'title5', 'Ripple Wave (power method)');

%% New plotRipples

plotRipples( ...
    'ripples1', tmp, ...
    'ripples2', ripples2, ...
    'lfpTriple', lfpTriple, ...
    'sharpWave', sharpWave, ...
    'sharpThresh', sharpThresh, ...
    'rippleSpect', rippleSpect, ...
    'rippleFreqs', rippleFreqs, ...
    'rippleWave', rippleWave, ...
    'rippleThresh', rippleThresh, ...
    'eventsToPlot', eventsToPlot ...
    );

%% Scatterplot thingy

lengths = (ripples(:, 3) - ripples(:, 1));
tmp = ripples(lengths > 0.0 & lengths < Inf, :);
idxs = round(tmp * sampleRate);
ranges = arrayfun(@colon, idxs(:, 1), idxs(:, 3), 'Uniform', false);
X = NaN(size(ranges));
Y = NaN(size(ranges));

for i = 1 : length(ranges)
    X(i) = max(sharpWave.Data(ranges{i}));
    Y(i) = max(abs(sharpWaveDeriv(ranges{i})));
end

scatter(X, Y);
xlabel('Max Sharp-Wave');
ylabel('Max Sharp-Wave Derivative');

hline(gca, 0.0125, 'r')



%%


    lsw = conv(sharpWave.Data, gaussfilt(2*0.15*sampleRate + 1), 'same');
    lsw = lsw(sharpWave.Time > tmp(10, 1) - 0.2 & sharpWave.Time < tmp(10, 3) + 0.2);
    sharpDiff = [0; diff(lsw)];
    sharpDiffDiff = [0; diff(sharpDiff)];
    figure();
    plot(sharpDiffDiff);

