function n = numDataChannels(this)
    if this.bOldBehavElectrData
        n = getXml(this, 'totNch');
    else
        n = getXml(this, 'nChannels');
    end
end