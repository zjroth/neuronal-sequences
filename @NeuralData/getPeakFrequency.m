%
% USAGE:
%
%    dPeakFreq = getPeakFrequency(this, vTimeWindow, vFrequencyWindow, bWhiten)
%
% DESCRIPTION:
%
%    Get the peak frequency in the given ranges using a spectrogram.
%
% ARGUMENTS:
%
%    vTimeWindow
%
%       The time window (in seconds) in which to look for a peak frequency; this
%       should be a 2-entry vector
%
%    vFrequencyWindow (default: [110, 190])
%
%       A vector specifying the minimum and maximum frequencies (in Hertz) to
%       use while computing the peak.
%
%    bWhiten (default: true)
%
%       A boolean specifying whether the signal should be whitened before
%       performing the FFT on it
%
% RETURNS:
%
%    dPeakFreq
%
%       The peak frequency (in Hertz) within the given windows
%
function dPeakFreq = getPeakFrequency(this, vTimeWindow, vFrequencyWindow, ...
                                      bWhiten)
    % Use the default spectrogram data by default
    if nargin < 5
        strUnits = 'seconds';
    end

    % Use the default spectrogram data by default
    if nargin < 4
        bWhiten = true;
    end

    % Use all available frequencies by default.
    if nargin < 3 || isempty(vFrequencyWindow)
        vFrequencyWindow = [110, 190];
    end

    % Get the signal to perform the FFT on.
    vIndexWindow = round(vTimeWindow * rawSampleRate(this));
    vSignal = mainLfp(this, vIndexWindow(1) : vIndexWindow(2));

    % Whiten the signal if requested.
    if bWhiten
        vSignal = WhiteningNoOrdEst(vSignal - mean(vSignal), 10);
    end

    % To reduce edge effects, shift the mean of the signal to zero.
    vSignal = vSignal - mean(vSignal);

    % Set up some values related to the transform.
    nPadOrder = 4;
    nLength = length(vSignal);
    nPointsInFFT = 2^(nextpow2(nLength) + nPadOrder);
    vFrequencies = rawSampleRate(this) / 2 * linspace(0, 1, nPointsInFFT / 2 + 1);

    % Transform the signal, retrieve the amplitudes of the returned frequencies
    % within the specified frequency range, find the max, and return the
    % corresponding frequency.
    vTransform = fft(vSignal, nPointsInFFT) / nLength;
    vAmplitudes = row(abs(vTransform(1 : nPointsInFFT / 2 + 1)));
    [~, nMaxIndex] = max(vAmplitudes .* (vFrequencies >= vFrequencyWindow(1) ...
                                         & vFrequencies <= vFrequencyWindow(2)));
    dPeakFreq = vFrequencies(nMaxIndex);
end


% %
% % USAGE:
% %
% %    dPeakFreq = getPeakFrequency(this, vTimeWindow, vFrequencyWindow, ...
% %                                 cellSpectParams)
% %
% % DESCRIPTION:
% %
% %    Get the peak frequency in the given ranges using a spectrogram.
% %
% % ARGUMENTS:
% %
% %    vTimeWindow
% %
% %       The time window in which to look for a peak frequency (a 2-entry vector)
% %
% %    vFrequencyWindow
% %
% %       A vector specifying the minimum and maximum frequencies (in Hertz) to
% %       use while computing the peak. Note that the frequency range is further
% %       restricted by the parameters used to compute the corresponding
% %       spectrogram.
% %
% %    cellSpectParams
% %
% %       A cell array of parameters that will be used to compute the spectrogram
% %       for this computation. See `help getRippleSpectrogram` for more
% %       information.
% %
% % RETURNS:
% %
% %    dPeakFreq
% %
% %       The peak frequency (in Hertz) within the given windows
% %
% % NOTES:
% %
% %    If necessary, this computes a spectrogram with the given (or default)
% %    parameters for the current main channel. If this spectrogram has not
% %    been precomputed, calling this method could take quite a long time.
% %
% function dPeakFreq = getPeakFrequency(this, vTimeWindow, vFrequencyWindow, ...
%                                       cellSpectParams)
%     % Use the default spectrogram data by default
%     if nargin < 4
%         cellSpectParams = {};
%     end
%
%     % Use all available frequencies by default.
%     if nargin < 3 || isempty(vFrequencyWindow)
%         vFrequencyWindow = [-Inf, Inf];
%     end
%
%     % Retrieve the spectrogram.
%     [mtxSpect, vSpectTimes, vSpectFreqs] = ...
%         getRippleSpectrogram(this, cellSpectParams{:});
%
%     % Get the indices corresponding to the given time window. Note that the
%     % indices extracted from this time window must correspond to the
%     % spectrogram, not to some other signal such as the sharp-wave (though
%     % this may in fact be the same). This assumes that the time window is
%     % given in seconds.
%     vTimeIndices = (vSpectTimes >= vTimeWindow(1) & ...
%                     vSpectTimes <= vTimeWindow(2));
%
%     % Retrieve the requested frequency indices.
%     vFreqIndices = (vSpectFreqs >= vFrequencyWindow(1) & ...
%                     vSpectFreqs <= vFrequencyWindow(2));
%
%     % Find the peak frequency.
%     vMaxFrequencyValues = max(mtxSpect(vFreqIndices, vTimeIndices), [], 2);
%     [~, dPeakFreq] = max(vMaxFrequencyValues);
% end