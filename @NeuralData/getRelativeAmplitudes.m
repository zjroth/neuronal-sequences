function vAmplitudes = getRelativeAmplitudes(this, mtxTimeWindows)
    nWindows = size(mtxTimeWindows, 1);
    vAmplitudes = zeros(nWindows, 1);

    objSharpWave = getSharpWave(this);

    for i = 1 : nWindows
        dMinTime = mtxTimeWindows(i, 1);
        dMaxTime = mtxTimeWindows(i, 2);

        vAmplitudes(i) = max(subseries(objSharpWave, dMinTime, dMaxTime));
    end
end
