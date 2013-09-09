% [strSection, nSectionRipple] = identifyRipple(this, nRipple)
function [strSection, nSectionRipple] = identifyRipple(this, nRipple)
    nPre = getRippleCount(this.pre);
    nMusc = getRippleCount(this.musc);
    nPost = getRippleCount(this.post);

    % Determine whether the current sequence is in pre, musc, or post
    % condition.
    if nRipple <= nPre
        nSectionRipple = nRipple;
        strSection = 'pre';
    elseif nRipple <= nPre + nMusc
        nSectionRipple = nRipple - nPre;
        strSection = 'musc';
    else
        nSectionRipple = nRipple - nPre - nMusc;
        strSection = 'post';
    end
end