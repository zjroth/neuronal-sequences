% function lfp = mainLfp(this)
function [lfp, ch] = mainLfp(this)
    lfp = this.currentLfps(:, 1);
    ch = this.currentChannels(1);
end