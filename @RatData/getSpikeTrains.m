% cellTrains = getSpikeTrains(this, bRemoveInterneurons)
function cellTrains = getSpikeTrains(this, bRemoveInterneurons)
    if nargin < 2
        bRemoveInterneurons = false;
    end

    cellTrains = [this.pre.getSpikeTrains(bRemoveInterneurons); ...
                  this.musc.getSpikeTrains(bRemoveInterneurons); ...
                  this.post.getSpikeTrains(bRemoveInterneurons)];
end