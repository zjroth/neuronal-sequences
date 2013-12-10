function vIndices = getIndicesFromWindow(this, vTimeWindow, strUnits)
    if nargin < 3
        strUnits = 'seconds';
    end

    switch strUnits
      case 'seconds'
        vIndexWindow = round(vTimeWindow * sampleRate(this));
      case 'milliseconds'
        vIndexWindow = round(vTimeWindow / 1000 * sampleRate(this));
      case 'index'
        vIndexWindow = vTimeWindow;
    end

    vIndices = (vIndexWindow(1) : vIndexWindow(2));
end