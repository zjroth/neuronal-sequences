% plotSpikeTrains(this, vSequenceNums, varargin)
function plotSpikeTrains(this, vSequenceNums, varargin)
    nPre = getRippleCount(this.pre);
    nMusc = getRippleCount(this.musc);
    nPost = getRippleCount(this.post);

    nSequences = length(vSequenceNums);

    % Set up the figure.
    figure();

    for i = 1 : nSequences
        nCurrSequence = vSequenceNums(i);

        % Determine whether the current sequence is in pre, musc, or post
        % condition.
        if nCurrSequence <= nPre
            nRipple = nCurrSequence;
            objNeuralData = this.pre;
        elseif nCurrSequence <= nPre + nMusc
            nRipple = nCurrSequence - nPre;
            objNeuralData = this.musc;
        else
            nRipple = nCurrSequence - nPre - nMusc;
            objNeuralData = this.post;
        end

        % Plot the sequence.
        subplot(nSequences, 1, i);
        %vRipple = objNeuralData.getRipples(nRipple);
        %vTimeWindow = vRipple([1, 3]);
        plotSpikeTrains(objNeuralData, nRipple, varargin{:});
    end
end