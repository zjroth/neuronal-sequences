% USAGE:
%    spikeraster(vSeq, ...)
%
% DESCRIPTION:
%    Plot the given sequence
%
% OPTIONAL PARAMETERS:
%    vOrdering (default: `unique(vSeq)`)
%       The ordering to use when displaying the neurons. This does not affect
%       the color used to display a given spike train.
%    mtxColors (default: `lines()`)
%       A matrix with three columns, each row of which represents an RGB color.
%       The colors will be used cyclically.
%    axPlot (default: `gca()`)
%       The axes on which to plot
function spikeraster(vSeq, varargin)
    nLength = length(vSeq);
    evtSeq = Event([0, nLength + 1], 1 : nLength, vSeq, 'sequence');
    plot(evtSeq, varargin{:});
end