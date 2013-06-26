% USAGE:
%
%    rippleWaveTs = computeRippleWave(data, ...)
%
% DESCRIPTION:
%
%    Compute a ripple-wave signal based on LFP or spectrogram data.
%
% ARGUMENTS:
%
%    data
%       The data to use to compute the ripple-wave signal. This can be either
%       LFP data or spectrogram data.
%
% OPTIONAL PARAMETERS:
%
%    dataIsSpect (default: false)
%       Specify whether the passed data is spectrogram data (or LFP data)
%
%    frequencyRange (default: [90, 180])
%       The frequency range (in Hertz) of the ripple events to consider
%
%    sampleRate (default: 20000)
%       The sample rate (in Herz) of the input signal
%
%    times
%       When `dataIsSpect` is true, this is used as the corresponding time data
%       for the output signal. If not specified, this will default to the vector
%       `(0 : size(data, 2) - 1) / outputRate`.
%
%    outputFile
%       A filename to save the intermediate data to. If not specified, this data
%       will not be saved.
%
%    outputRate (default: 1250)
%       The sample rate (in Hertz) of the output signal
%
%    windowWidth (default: 0.1)
%       The width of the window (in seconds) to use in computing the spectrogram
%
% RETURNS:
%
%    rippleWaveTs
%       A timeseries object whose data is the resultant ripple-wave signal
%
function rippleWaveTs = computeRippleWave(data, varargin)
    %=======================================================================
    % Initialization and default optional parameter values
    %=======================================================================

    % Properties of the original signal
    sampleRate = 2e4;

    % Parameters for the spectrogram computation.
    outputRate = 1250;
    frequencyRange = [90, 180];
    windowWidth = 0.1;

    % By default, we assume that the data passed in is LFP data, not spectrogram
    % data. Also, we don't save the computed data by default.
    dataIsSpect = false;

    % Replace the default optional parameter values with any values that were
    % passed in `varargin`.
    parseNamedParams();

    % The step of the window for the spectrogram depends on the desired output
    % rate.
    windowStep = 1 / outputRate;

    % The data passed in could be LFP data or spectrogram data.
    if ~dataIsSpect
        assert(isvector(data), ...
            ['computeRippleWave: LFP data must be in vector ' ...
            'form. To use pre-computed spectrogram data, set the' ...
            'optional parameter ''dataIsSpect'' to true']);

        lfp = data;
    else
        spect = data;

        % Ensure that there is time data for the spectrogram/output.
        if exist('times', 'variable')
            assert(isvector(times) && length(times) == size(spect, 2), ...
                ['computeRippleWave: the specified time data must be a vector ' ...
                'of the same length as the number of columns of the spectrogram ' ...
                'data.']);
        else
            times = (0 : size(spect, 2) - 1) / outputRate;
        end
    end

    %=======================================================================
    % Actual computations
    %=======================================================================

    if ~dataIsSpect
        % Compute the spectrogram if necessary.
        [spect, times, frequencies] = rippleSpectrogram( ...
            lfp(:)           ,                           ...
            'windowWidth'    , windowWidth,              ...
            'windowStep'     , windowStep,               ...
            'sampleRate'     , sampleRate,               ...
            'frequencyRange' , frequencyRange);

        % Save the computed data if a file name was provided.
        if exist('outputFile', 'variable')
            save(outputFile, 'lfp', 'spect', 'times', 'frequencies', ...
                'rippleWave', 'windowWidth', 'windowStep', 'sampleRate', ...
                'outputRate', 'frequencyRange');
        end
    end

    % Reduce the spectrogram to the return signal.
    rippleWave = zscore(mean(spect, 1));
    rippleWaveTs = timeseries(rippleWave(:), times(:));
end
