function img = plotRipplesVsSpikes(this, varargin)
    parseNamedParams();

    ripples = getRipples(this);
    cells = groupSpikes(this);

    if ~exist('neurons', 'var')
        neurons = (1 : length(cells));
    end

    nCells = length(neurons);
    nRipples = size(ripples, 1);

    img = getRippleSpikeMatrix(this);

    % Remove interneurons identified from picture.
    interneurons = [66, 77, 90];
    img = img(setdiff(1:nCells, interneurons, 'stable'), :);

    totalSpikesPerRipple = sum(img, 1);
    totalSpikesPerNeuron = sum(img, 2);

    [~, idxs1] = sort(totalSpikesPerRipple, 'descend');
    [~, idxs2] = sort(totalSpikesPerNeuron);
    img = img(:, idxs1); % sort by ripple size, not neuron firing rate

    img(nCells + 1, :) = totalSpikesPerRipple;

    figure();
    cmap = [0 0 0; 0 0 .5; .5 .5 1; 0 .7 0; .7 .7 .2; 1 .5 0; 1 .2 .2; .7 0 0];
    colormap(cmap);

    C = 1 * (img(1:end - 3, :) > 1);
    dots = C' * C;

    for r = 1 : nRipples
        c = dots(r, :);
        [overlap, idxs] = sort(c, 'descend');
        C_tmp = bsxfun(@and, C(:, idxs), C(:, idxs(1)));
        imagesc([overlap / overlap(1); C(:, idxs) + C_tmp]);
        hline(1.5);
        colorbar();
        xlabel('Ripple number');
        ylabel('Cluster/cell number');
        title(['Ripple ' num2str(r)]);

        pause();
    end
end