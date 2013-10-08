%% Load in the data for the desired rat and recording day.
objRatData = RatData('~/data/pastalkova/A543/2012-04-22/');

% Since this data has been saved, use it (for a slight speed increase).
% This could be replaced with the following code:
%
%   cellSeqs = getRippleSequences(objRatData);
%   mtxRipples = getRipples(objRatData);
%
%   nPre = getRippleCount(objRatData.pre);
%   nMusc = getRippleCount(objRatData.musc);
%   nPost = getRippleCount(objRatData.post);
%
%   mtxNeuronActivity = toMatrix(cellSeqs);
%   mtxNumCoactive = mtxNeuronActivity * mtxNeuronActivity';
%

load('sequences/data/A543-2.mat');
cellSeqs = [cellSeqsPre; cellSeqsMusc; cellSeqsPost];
mtxRipples = [mtxPreMuscRipples; mtxMuscRipples; mtxPostMuscRipples];

nPre = size(mtxPreMuscRipples, 1);
nMusc = size(mtxMuscRipples, 1);
nPost = size(mtxPostMuscRipples, 1);

mtxNeuronActivity = toMatrix(cellSeqs);
mtxNumCoactive = mtxNeuronActivity * mtxNeuronActivity';

% Recompute the matrix of rho values.
tic;
[mtxRho, vIncluded] = computeRhoMatrix(cellSeqs, 0);
toc;

%%
clear functions
plotSequenceStats(cellSeqsPre, mtxPreMuscRipples, 'Pre-muscimol stats')
plotSequenceStats(cellSeqsMusc, mtxMuscRipples, 'Muscimol stats')
plotSequenceStats(cellSeqsPost, mtxPostMuscRipples, 'Post-muscimol stats')



