%
% USAGE:
%
%    setCurrentChannels(this, nMain, nLow, nHigh)
%
% DESCRIPTION:
%
%    Set the LFP channels that are to be used by this object
%
% ARGUMENTS:
%
%    nMain
%
%       A channel with high-frequency ripple oscillations
%
%    nLow
%
%       A channel that drops during ripple activity; used as the lower portion
%       of the sharp-wave envelope.
%
%    nHigh
%
%       A channel that raises during ripple activity; used as the upper portion
%       of the sharp-wave envelope.
%
% NOTE:
%
%    Although Neuroscope is zero-indexed, all channels here are one-indexed.
%
function setCurrentChannels(this, nMain, nLow, nHigh)
    % Define the array of current channels.
    this.currentChannels = [nMain, nLow, nHigh];

    % In case LFPs had been loaded from a previous set of channels,
    % clear those here.
    this.currentLfps = [];
end