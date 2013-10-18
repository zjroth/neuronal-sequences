%
% USAGE:
%
%    plotRippleSpikeTrains(this, nRipple, vTimeWindow, vOrdering, mtxColors)
%
% DESCRIPTION:
%
%    Plot the spike trains during the given ripple event
%
% ARGUMENTS:
%
%    nRipple
%
%       The ripple event number
%
%    vTimeWindow (default: based on `cellTrains`)
%
%       The window to display
%
%    vOrdering (default: `1 : length(cellTrains)`)
%
%       The ordering to use when displaying the neurons. This does not affect
%       the color used to display a given spike train.
%
%    mtxColors (default: `lines()`)
%
%       A matrix with three columns, each row of which represents an RGB color.
%       The colors will be used cyclically.
%
function plotRippleSpikeTrains(this, nRipple, varargin)
    vRipple = getRipples(this, nRipple);
    vTimeWindow = vRipple([1, 3]);
    plotSpikeTrains(getSpikeTrains(this), vTimeWindow, varargin{:});
end
