% rate = rawSampleRate(this)
function rate = rawSampleRate(this)
    rate = this.getXml('SampleRate');
end