% function lfp = highLfp(this)
function [lfp, ch] = highLfp(this, indices)
    if isempty(this.currentLfps)
        this.loadChannels();
    end

    if nargin < 2
        lfp = this.currentLfps(:, 3);
    else
        lfp = this.currentLfps(indices, 3);
    end

    ch = this.currentChannels(3);
end