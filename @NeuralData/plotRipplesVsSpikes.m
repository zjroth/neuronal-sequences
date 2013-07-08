function fig = plotRipplesVsSpikes(this, ripples)
    spikes = groupSpikes(this);

    nSikes = length(spikes);
    nRipples = size(ripples, 1);

    img = zeros(nSpikes, nRipples);

    % Build the image.
    for i = 1 : nRipples
        s = ripples(i, 1);
        e = ripples(i, 3);

        for j = 1 : nSpikes
            img(j, i) = nnz(spikes{j} >= s & spikes{j} <= e);
        end
    end

    figure();
    imagesc(img);
    colorbar();
    xlabel('Ripple number');
    ylabel('Cluster/cell number');
    title('Occurrence of spikes in ripples');
end