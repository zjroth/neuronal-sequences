% function lfp = lowLfp(this)
function [lfp, ch] = lowLfp(this, indices)
    if isempty(this.currentLfps)
        this.loadChannels();
    end

    if nargin < 2
        lfp = this.currentLfps(:, 2);
    else
        lfp = this.currentLfps(indices, 2);
    end

    ch = this.currentChannels(2);
end