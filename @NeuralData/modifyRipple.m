function modifyRipple(this, nRipple, nStart, nEnd)
    vSharpWave = getSharpWave(this);
    [~, nPeak] = max(vSharpWave(nStart : nEnd));
    nPeak = nStart + (nPeak - 1);
    this.current.ripples(nRipple, :) = [nStart, nPeak, nEnd];
end
