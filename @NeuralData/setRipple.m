function setRipple(this, rippleNum, vStartPeakEnd)
    assert(isrow(vStartPeakEnd) && length(vStartPeakEnd) == 3);
    this.current.ripples(rippleNum, :) = vStartPeakEnd;
end