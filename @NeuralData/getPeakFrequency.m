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

function [whiteV] = WhiteningNoOrdEst(v, p, arType)
    % whiten the signal represented by vector v. This function does not
    % estimate the order of AR model
    %
    % v:            vector to be whitened
    % p:            the order of AR model
    % arType:       1: using ARFIT for AR estimation
    %               2: using BURG method for AR estimation
    %
    % whiteV:       whitened vector

    %%%%%%%%% check arguments
    if nargin<2
        disp('At least two arguments are needed for this function.');
        return;
    elseif nargin == 2
        arType = 1; % by default, use ARFIT to estimate the parameters
    elseif nargin > 3
        disp('Too many input arguments.');
        return;
    end

    if(arType == 1) % using arfit
        [w,Atmp] = arfit(v,p,p);
        A = [1 -Atmp];
    else % using burg method
        [w,A] = arburg(v,p);
    end

    whiteV = filter(A,1,v);
end
