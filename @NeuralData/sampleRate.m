% rate = sampleRate(this)
function rate = sampleRate(this)
    rate = this.getXml('lfpSampleRate');
end