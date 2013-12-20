% USAGE:
%
%    nMaxElt = maxActive(cellSeqs)
%
% DESCRIPTION:
%
%    Find the maximum active element in a list (cell array) of
%    sequences.
function nMaxElt = maxActive(cellSeqs)
    nMaxElt = max(cellfun(@myMax, cellSeqs));
end

% For convenience, we want the max of an empty sequence to be negative
% infinity.
function n = myMax(v)
    n = max(v);

    if isempty(n)
        n = -Inf;
    end
end