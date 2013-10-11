%
% USAGE:
%
%    strPosition = classifyPosition(vPoint, stctRegions)
%
% DESCRIPTION:
%
%    Find the first region that the given point belongs to.
%
% ARGUMENTS:
%
%    vPoint
%
%       The point to check as a vector [x, y]
%
%    stctRegions
%
%       A struct. The value of each field should be a cell array of rectangles
%       of the form [left, bottom, width, height].
%
% RETURNS:
%
%    strPosition
%
%       The field name of the first region found to contain the provided point.
%       If no containing region is found, this will be the empty string.
%
function strPosition = classifyPosition(vPoint, stctRegions)
    % `stctRegions` is a struct whose fields are names of regions; the
    % content of the field should be a cell array of regions (rectangles).
    cellFieldNames = fields(stctRegions);
    nFields = length(cellFieldNames);
    bIsClassified = false;
    strPosition = '';

    % For each region, check to see whether the given point is in that region.
    i = 1;

    while ~bIsClassified && i <= nFields
        % Retrieve the collection of sub-regions that define this region.
        strField = cellFieldNames{i};
        cellRegions = stctRegions.(strField);

        % Check each rectangular sub-region to see whether the point belongs to
        % the current region.
        j = 1;

        while ~bIsClassified && j <= numel(cellRegions)
            if inrectangle(vPoint, cellRegions{j})
                strPosition = strField;
                bIsClassified = true;
            end
        end
    end
end