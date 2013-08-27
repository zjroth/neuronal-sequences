% cellSequences = getRippleSequences(this, varargin)
function cellSequences = getRippleSequences(this, varargin)
    % Parse the named parameters.
    removeInterneurons = false;
    parseNamedParams();

    % Retrieve the number of ripples, and initialize the return variable.
    nRipples = size(this.getRipples(), 1);
    cellSequences = cell(nRipples, 1);

    % Loop through the ripples to get the sequence for each.
    for i = 1 : nRipples
        cellSequences{i} = this.getRippleSequence(i, ...
            'removeInterneurons', removeInterneurons);
    end
end
