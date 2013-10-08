% plotSpikeTrains(this, vSequenceNums, varargin)
function plotSpikeTrains(this, vSequenceNums, varargin)
    nPre = getRippleCount(this.pre);
    nMusc = getRippleCount(this.musc);
    nPost = getRippleCount(this.post);

    nSequences = length(vSequenceNums);

    % Set up the figure.
    figure();

    for i = 1 : nSequences
        [strSection, nRipple] = identifyRipple(this, vSequenceNums(i));

        % Plot the sequence.
        subplot(nSequences, 1, i);
        plotRippleSpikeTrains(this.(strSection), nRipple, varargin{:});
    end
end