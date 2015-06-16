function cellSets = spikesets(vSeq)
    nLength = length(vSeq);
    evtSeq = Event([0, nLength + 1], 1 : nLength, vSeq, 'sequence');
    cellSets = spikeTrains(evtSeq);
end
