%
% USAGE:
%
%    saveEventsAndSequences(strBaseFolder, strCacheDir)
%
% DESCRIPTION:
%
%    Save the events and sequences for a specified
%
% ARGUMENTS:
%
%    strBaseFolder
%
%       The location to save to. Please see the note below for more information.
%
%    strCacheDir
%
%       A cache directory for the class `NeuralData` to use
%
%    cellParams
%
%       A cell array of named parameters to pass to the method
%       `NeuralData.detectRipples`
%
% NOTES:
%
%    The directory specified in `strBaseFolder` will store some analysis data
%    related to an animal on a particular day (which will involve multiple
%    recordings). This function requires that this directory have a certain
%    structure:
%
%       strBaseFolder
%          |__ pre
%          |__ musc
%          |__ channels.mat
%
%    The files 'pre' and 'musc' should be links to the directories containing
%    the raw data for the pre-muscimol and muscimol recordings on this
%    particular day.
%
%    The file 'channels.mat' should contain two variables `pre` and `musc`, each
%    of which should be a struct with the fields `main`, `low`, and `high`;
%    these fields tell the function which channels should be loaded from the raw
%    data.
%
%    Three files are saved to the directory `strBaseFolder` by this function.
%    Two of these files, 'events.mat' and 'sequences.mat' both contain the
%    variables `pre` and `musc`, each of which is a structure with the fields
%    `ripple`, `placeField`, and `wheel`. The third file that is saved by this
%    file is 'parameters.mat', which contains the value of `cellParams`.
%
function saveEventsAndSequences(strBaseFolder, strCacheDir, cellParams)
    % Load the recording data.
    strPreDir = fullfile(strBaseFolder, 'pre');
    strMuscDir = fullfile(strBaseFolder, 'musc');

    objPre = NeuralData(strPreDir, strCacheDir);
    objMusc = NeuralData(strMuscDir, strCacheDir);

    % Retrieve the channels and set the recording data to use them.
    stctChannels = load(fullfile(strBaseFolder, 'channels.mat'));
    objPre.setCurrentChannels(stctChannels.pre.main, stctChannels.pre.low, ...
                              stctChannels.pre.high);
    objMusc.setCurrentChannels(stctChannels.musc.main, stctChannels.musc.low, ...
                              stctChannels.musc.high);

    % Collect the events.
    mtxRipplesPre = detectRipples(objPre, cellParams{:});
    mtxRipplesMusc = detectRipples(objMusc, cellParams{:});

    stctEvents.pre.ripple = mtxRipplesPre(:, [1, 3]);
    stctEvents.musc.ripple = mtxRipplesMusc(:, [1, 3]);

    stctEvents.pre.placeField = getPlaceFieldIntervals(objPre);
    stctEvents.musc.placeField = getPlaceFieldIntervals(objMusc);

    stctEvents.pre.wheel = getWheelIntervals(objPre);
    stctEvents.musc.wheel = getWheelIntervals(objMusc);

    % Collect the sequences.
    stctSequences.pre.ripple = getSequences(objPre, stctEvents.pre.ripple, true);
    stctSequences.musc.ripple = getSequences(objMusc, stctEvents.musc.ripple, true);

    stctSequences.pre.placeField = getSequences(objPre, stctEvents.pre.placeField, true);
    stctSequences.musc.placeField = getSequences(objMusc, stctEvents.musc.placeField, true);

    stctSequences.pre.wheel = getSequences(objPre, stctEvents.pre.wheel, true);
    stctSequences.musc.wheel = getSequences(objMusc, stctEvents.musc.wheel, true);

    % Save the parameter list and the structures to their respective files.
    save(fullfile(strBaseFolder, 'parameters.mat'), '-v7.3', 'cellParams');
    save(fullfile(strBaseFolder, 'events.mat'), '-v7.3', '-struct', 'stctEvents');
    save(fullfile(strBaseFolder, 'sequences.mat'), '-v7.3', '-struct', 'stctSequences');
end
