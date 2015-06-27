function browseSequences(cellEvents)
    nEvents = length(cellEvents);
    navigateFigures(nEvents, @plotLocal);

    function plotLocal(nEvent)
        plot(cellEvents{nEvent}, orderCells(cellEvents{nEvent}))
        evt = cellEvents{nEvent};
        plot(evt, orderCells(evt));

        title(['Event #' num2str(nEvent) ' (type: ' evt.type ')'], ...
              'Interpreter', 'none');
        xlabel('Time (s)');
        ylabel('Neuron (sorted by center-of-mass)');
    end
end
