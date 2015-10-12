% USAGE:
%    detectInterneurons(this)
%
% DESCRIPTION:
%    Detect cells that are interneurons in this data. The results of this
%    computation are stored and can be retrieved using the method
%    `getInterneurons`.
function detectInterneurons(this)
    % The minimum firing rate of an interneuron (in Hertz).
    dMinFiringRate = 10;

    % Count the number of times that each cell fired.
    vSpikeCounts = row(accumarray(col(getSpike(this, 'totclu')), 1));

    % To compute the firing rates, divide the total number of spikes by the
    % total number of samples; convert this to Hertz by multiplying by the
    % sample rate.
    vFiringRates = vSpikeCounts / getRecordingDuration(this);

    % Extract the cells that have at least the minimum specified firing rate,
    % and combine that list with the list of interneurons in the `Clu` field.
    vSavedList = getClu(this, 'isIntern');
    vHighSpiking = (vFiringRates > dMinFiringRate);
    vInterneurons = find(vHighSpiking | vSavedList);

    % Store the interneurons in this object so that they don't need to be
    % detected again.
    this.data.interneurons = vInterneurons;
end