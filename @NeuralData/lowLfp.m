% function lfp = lowLfp(this)
function [lfp, ch] = lowLfp(this)
    lfp = this.currentLfps(:, 2);
    ch = this.currentChannels(2);
end