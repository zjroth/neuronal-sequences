% USAGE:
%    vInterneurons = getInterneurons(this)
%
% DESCRIPTION:
%    Retrieve the list of interneurons from this data
%
% RETURNS:
%    vInterneurons
%       A vector containing the indices of the interneurons
function vInterneurons = getInterneurons(this)
    if ~isfield(this.data, 'interneurons')
        detectInterneurons(this);
    end

    vInterneurons = this.data.interneurons;
end