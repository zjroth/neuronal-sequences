%
% USAGE:
%
%    mtxLocations = getSpikeLocations(this)
%
% DESCRIPTION:
%
%    Get the locations (units in millimeters) of the animal when spikes occur
%
% RETURNS:
%
%    mtxLocations
%
%       A 2-column matrix whose rows represent positions with x and y
%       coordinates being stored in the first and second columns, respectively.
%
function mtxLocations = getSpikeLocations(this)
    mtxPoints = [this.getSpike('xMM'), this.getSpike('yMM')];
end