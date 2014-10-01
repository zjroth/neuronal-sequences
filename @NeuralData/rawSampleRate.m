% rate = rawSampleRate(this)
function rate = rawSampleRate(this)
    if this.bOldBehavElectrData
        rate = 20000;
    else
        rate = this.getXml('SampleRate');
    end
end