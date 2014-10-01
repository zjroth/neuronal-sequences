% USAGE:
%    mtxLocations = getLocations(this)
%
% DESCRIPTION:
%    Get the locations (units in millimeters) of the animal throughout the trial.
%
% RETURNS:
%    mtxLocations
%       A 2-column matrix whose rows represent positions with x and y
%       coordinates being stored in the first and second columns, respectively.
function mtxPoints = getLocations(this)
    if this.bOldBehavElectrData
        strFieldX = 'X';
        strFieldY = 'Y';
    else
        strFieldX = 'xMM';
        strFieldY = 'yMM';
    end

    mtxPoints = [getTrack(this, strFieldX), getTrack(this, strFieldY)];
end
