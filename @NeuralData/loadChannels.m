% function loadChannels(this)
function loadChannels(this)
    % The set of current channels must be set before calling this function.
    assert(~isempty(this.currentChannels), ...
           ['method `setCurrentChannels` must be called before ' ...
            'invoking `loadChannels`']

    % Use the FMA toolbox to load the binary data.
    datFileName = fullfile(this.baseFolder, [this.baseFileName '.dat']);

    this.currentLfps = [];

    % Load each of the channels
    for i = 1 : 3
        % Each channel must be extracted from the data, which is an expensive
        % operation. So, when a channel is extracted, the extracted data is
        % saved to a separate file. Set the name of the file here.
        strFilename = fullfile(                    ...
            [this.baseFolder filesep() 'lfps'], ...
            ['ch' num2str(this.currentChannels(i)) '.mat']);

        % If the file already exists, simply load the data from that file.
        if exist(strFilename, 'file')
            load(strFilename, 'lfp');
            this.currentLfps(:, i) = lfp;
            clear('lfp');
        else
            % ...otherwise, extract the data and save it to a file.
            lfp = LoadBinary(datFileName,            ...
                'nChannels', this.numDataChannels(), ...
                'channels', this.currentChannels(i));

            save(strFilename, 'lfp');
            this.currentLfps(:, i) = lfp;
            clear('lfp');
        end
    end

    % Finally, set the raw sample times corresponding to the loaded LFPs.
    this.rawSampleTimes = (0 : size(this.currentLfps, 1) - 1) / this.rawSampleRate;
end