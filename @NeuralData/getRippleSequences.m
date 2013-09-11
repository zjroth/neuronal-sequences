% cellSequences = getRippleSequences(this, varargin)
function cellSequences = getRippleSequences(this, varargin)
    mtxRipples = this.getRipples();
    mtxTimeWindows = mtxRipples(:, [1, 3]);
    cellSequences = getSequences(this, mtxTimeWindows, varargin{:});
end
