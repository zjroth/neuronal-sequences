% function setCurrentChannels(this, main, low, high)
function setCurrentChannels(this, main, low, high)
    % Define the array of current channels.
    this.currentChannels = [main, low, high];

    % In case LFPs had been loaded from a previous set of channels,
    % clear those here.
    this.currentLfps = [];
end