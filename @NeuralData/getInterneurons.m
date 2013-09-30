% vInterneurons = getInterneurons(this)
function vInterneurons = getInterneurons(this)
    if ~isfield(this.data, 'interneurons')
        detectInterneurons(this);
    end

    vInterneurons = this.data.interneurons;
end