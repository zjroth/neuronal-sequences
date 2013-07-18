% function lfp = mainLfp(this)
function [lfp, ch] = mainLfp(this, indices)
    if nargin < 2
        lfp = this.currentLfps(:, 1);
    else
        lfp = this.currentLfps(indices, 1);
    end

    ch = this.currentChannels(1);
end