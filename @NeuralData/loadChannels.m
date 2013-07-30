% function loadChannels(this, main, low, high)
function loadChannels(this, main, low, high)
    % Use the FMA toolbox to load the binary data.
    datFileName = fullfile(this.baseFolder, [this.baseFileName '.dat']);

    this.setCurrentChannels(main, low, high);
    channels = [main, low, high];

    this.currentLfps = [];

    % For each channel, check to see if the channel has been saved separately
    % before trying to load it from the main .dat file. Otherwise, load the
    % channel and then save.
    for i = 1 : 3
        filename = fullfile(                    ...
            [this.baseFolder filesep() 'lfps'], ...
            ['ch' num2str(channels(i)) '.mat']);

        if exist(filename, 'file')
            load(filename, 'lfp');
            this.currentLfps(:, i) = lfp;
            clear('lfp');
        else
            lfp = LoadBinary(datFileName,            ...
                'nChannels', this.numDataChannels(), ...
                'channels', channels(i));

            save(filename, 'lfp');
            this.currentLfps(:, i) = lfp;
            clear('lfp');
        end
    end

    this.rawSampleTimes = (0 : size(this.currentLfps, 1) - 1) / this.rawSampleRate;
end