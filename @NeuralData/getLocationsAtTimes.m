% USAGE:
%    mtxPoints = getLocationsAtTimes(this, vTimes, strUnits)
%
% DESCRIPTION:
%    Get the sequences of neuron firings in the given time windows
%
% ARGUMENTS:
%    vTimes
%       The times at which to retrieve location information
%    strUnits (default: 'seconds')
%       Any of the strings 'seconds', 'milliseconds', and 'indices'
%
% RETURNS:
%    mtxPoints
%       The requested locations as a 2-column matrix with x and y coordinates
%       given in the first and second columns, respectively.
function mtxPoints = getLocationsAtTimes(this, vTimes, strUnits)
    if nargin < 3
        strUnits = 'seconds';
    end

    switch strUnits
      case 'seconds'
        vIndex = round(vTimes * sampleRate(this));
      case 'milliseconds'
        vIndex = round(vTimes / 1000 * sampleRate(this));
      case 'indices'
        vIndex = vTimes;
    end

    mtxLocations = getLocations(this);
    mtxPoints = mtxLocations(vIndex, :);
end
