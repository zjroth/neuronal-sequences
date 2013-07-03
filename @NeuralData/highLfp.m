% function lfp = highLfp(this)
function [lfp, ch] = highLfp(this)
    lfp = this.currentLfps(:, 3);
    ch = this.currentChannels(3);
end