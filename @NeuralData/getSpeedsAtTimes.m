%
% USAGE:
%
%    vSpeeds = getSpeedsAtTimes(this, vTimes, dWindowWidth, strUnits)
%
% DESCRIPTION:
%
%    Retrieve the speed of the animal at the given times, potentially averaging
%    over time windows surrounding those points.
%
% ARGUMENTS:
%
%    vTimes
%
%       A vector containing the times at which to retrieve the animal's speed
%
%    dWindowWidth (default: 0)
%
%       The width of the windows to use for averaging speeds over. The
%       windows will be centered at the provided times and have total width
%       as specified in this parameter, depending on the units.
%
%    strUnits (default: 'seconds')
%
%       A string specifying the units of the given times; can be 'seconds',
%       'milliseconds', or 'indices'
%
% RETURNS:
%
%    vSpeeds
%
%       A vector containing the requested speeds
%
function vSpeeds = getSpeedsAtTimes(this, vTimes, dWindowWidth, strUnits)
    if nargin < 3
        dWindowWidth = 0;
    end

    if nargin < 4 || isempty(strUnits)
        strUnits = 'seconds';
    end

    % Define a matrix of windows based on the given window width and the given
    % times.
    mtxWindows = bsxfun(@plus, col(vTimes), ...
                        [-dWindowWidth / 2, dWindowWidth / 2]);

    % Convert the above-determined windows into index windows.
    switch strUnits
      case 'seconds'
        mtxIndices = round(mtxWindows * sampleRate(this));
      case 'milliseconds'
        mtxIndices = round(mtxWindows ./ 1000 * sampleRate(this));
      case 'indices'
        mtxIndices = mtxWindows;
    end

    % Expand the index windows into complete lists of indices, and then
    % retrieve the speeds and average them.
    cellIndices = arrayfun(@colon, mtxIndices(:, 1), mtxIndices(:, 2), ...
                           'UniformOutput', false);
    vSpeeds = mean(this.Track.speed_MMsec(vertcat(cellIndices{:})), 2);
end