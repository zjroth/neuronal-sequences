% rate = sampleRate(this)
function rate = sampleRate(this)
    if ~this.bOldBehavElectrData
        rate = getXml(this, 'lfpSampleRate');
    else
        rate = getXml(this, 'SamplingFrequency');
    end
end