%
% USAGE:
%
%    vPeakFreqs = getPeakFrequencies(this, mtxTimeWindows, vFrequencyWindow, ...
%                                    cellSpectParams)
%
% DESCRIPTION:
%
%    Get the peak frequencies in the given ranges using a spectrogram.
%
% ARGUMENTS:
%
%    mtxTimeWindows
%
%       The time windows in which to look for peak frequencies. This should
%       be a 2-column matrix with each row representing a time window.
%
%    vFrequencyWindow
%
%       A vector specifying the minimum and maximum frequencies (in Hertz) to
%       use while computing the peak. Note that the frequency range is further
%       restricted by the parameters used to compute the corresponding
%       spectrogram.
%
%    cellSpectParams
%
%       A cell array of parameters that will be used to compute the spectrogram
%       for this computation. See `help getRippleSpectrogram` for more
%       information.
%
% RETURNS:
%
%    vPeakFreqs
%
%       The peak frequencies (in Hertz) within the given windows
%
% NOTES:
%
%    If necessary, this computes a spectrogram with the given (or default)
%    parameters for the current main channel. If this spectrogram has not
%    been precomputed, calling this method could take quite a long time.
%
function vPeakFreqs = getPeakFrequencies(this, mtxTimeWindows, varargin)
    nWindows = size(mtxTimeWindows, 1);
    vPeakFreqs = zeros(nWindows, 1);

    for i = 1 : nWindows
        vTimeWindow = mtxTimeWindows(i, :);
        vPeakFreqs(i) = getPeakFrequency(this, vTimeWindow, varargin{:});
    end
end

% %
% % USAGE:
% %
% %    vPeakFreqs = getPeakFrequencies(this, mtxTimeWindows, vFrequencyWindow, ...
% %                                    cellSpectParams)
% %
% % DESCRIPTION:
% %
% %    Get the peak frequencies in the given ranges using a spectrogram.
% %
% % ARGUMENTS:
% %
% %    mtxTimeWindows
% %
% %       The time windows in which to look for peak frequencies. This should
% %       be a 2-column matrix with each row representing a time window.
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
% %    vPeakFreqs
% %
% %       The peak frequencies (in Hertz) within the given windows
% %
% % NOTES:
% %
% %    If necessary, this computes a spectrogram with the given (or default)
% %    parameters for the current main channel. If this spectrogram has not
% %    been precomputed, calling this method could take quite a long time.
% %
% function vPeakFreqs = getPeakFrequencies(this, mtxTimeWindows, vFrequencyWindow, ...
%                                          cellSpectParams)
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
%     nWindows = size(mtxTimeWindows, 1);
%     vPeakFreqs = zeros(nWindows, 1);
%
%     % Retrieve the spectrogram.
%     [mtxSpect, vSpectTimes, vSpectFreqs] = ...
%         getRippleSpectrogram(this, cellSpectParams{:});
%
%     for i = 1 : nWindows
%         % Get the indices corresponding to the given time window. Note that the
%         % indices extracted from this time window must correspond to the
%         % spectrogram, not to some other signal such as the sharp-wave (though
%         % this may in fact be the same). This assumes that the time window is
%         % given in seconds.
%         vTimeIndices = (vSpectTimes >= mtxTimeWindows(i, 1) & ...
%                         vSpectTimes <= mtxTimeWindows(i, 2));
%
%         % Retrieve the requested frequency indices.
%         vFreqIndices = (vSpectFreqs >= vFrequencyWindow(1) & ...
%                         vSpectFreqs <= vFrequencyWindow(2));
%
%         % Find the peak frequency.
%         vMaxFrequencyValues = max(mtxSpect(vFreqIndices, vTimeIndices), [], 2);
%         [~, nPeakIndex] = max(vMaxFrequencyValues);
%         vPeakFreqs(i) = vSpectFreqs(nPeakIndex + find(vFreqIndices, 1) - 1);
%     end
% end