%------------------------------------------------------------------------------
% Usage:
%    rplPower = computeRippleWave()
% Description:
%    Here is Eva's original comment for this code: "detect ripple power".
% Arguments:
%    lfp
%       The LFP to detect the "ripple power" of
%    sampleRate
%       The rate at which the LFP was sampled
% Returns:
%    rplPower
%       .
%------------------------------------------------------------------------------
function rplPower = computeRippleWave(lfp, passBand, sampleRate, smoothingFilter)
    % The frequency ranges (in Hertz) for theta waves and ripple waves.
    rplFreqRange = passBand;
    % thetaFreqRange = [6, 10];

    %
    rplTimeWindow = 0.25;
    % thetaWindow = 0.5;

    % Compute the actual short-time Fourier transforms for the desired
    % frequencies.
    [rplSpect, rplTimes, rplFreqs] = MTSpectrogram( ...
        lfp         ,                               ...
        'frequency' , sampleRate,                   ...
        'window'    , rplTimeWindow,                ...
        'step'      , (1 / sampleRate),             ...
        'range'     , rplFreqRange                  ...
    );

    % [thetaSpect, thetaTimes, thetaFreqs] = MTSpectrogram( ...
    %     lfp         ,                                     ...
    %     'frequency' , sampleRate,                         ...
    %     'window'    , thetaTimeWindow,                    ...
    %     'step'      , (1 / sampleRate),                   ...
    %     'range'     , thetaFreqRange                      ...
    % );

    % We want to account for the fact that "the power spectrum of intracortical
    % local field potential (LFP) often scales as 1/f^2". Note that this fact
    % seems not to hold for frequencies below about 10 Hz, which means that
    % we should probably be using a different method for the theta spectrogram.
    rplSpect = scaleLfpSpectrogram(rplSpect, rplFreqs);
    % scaledThetaSpect = scaleLfpSpectrogram(thetaSpect, thetaFreqs);

    % To account for some artifacts due to computing a spectrogram, we want
    % to smooth across frequencies in the spectrograms.
    %smoothingFilter = gausswin(20);
    %smoothingFilter = smoothingFilter / sum(smoothingFilter);
    rplSpect = conv2(rplSpect, smoothingFilter, 'same');

    % We want to combine the transforms for each window. For now, we will take
    % the maximum value found for each frequency range (at a given time).
    rplMax = max(rplSpect, [], 1);
    % thetaMax = max(thetaSpect, [], 1);

    % We probably want to use `interp1` here. This in combination with the time
    % data returned by the `spectrogram` calls and with the length of
    % `lfp` should allow us to compute R(t) = S_theta(t) / S_ripple(t) for
    % the desired values of t, except for maybe values near the ends of the
    % vectors.
    rplPowerTmp = (rplMax - mean(rplMax)) / std(rplMax);
    rplPower = zeros(size(lfp));
    rplPower(round(rplTimes * sampleRate)) = rplPowerTmp;
end

%------------------------------------------------------------------------------
% Usage:
%    scaled = scaleLfpSpectrogram(spect)
% Description:
%    .
% Arguments:
%    spect
%       .
% Returns:
%    scaled
%       .
%------------------------------------------------------------------------------
function scaled = scaleLfpSpectrogram(spect, freqs)
    scaled = spect;

    for i = 1:length(freqs)
        scaled(i, :) = log(scaled(i, :)) * log(freqs(i));
    end
end
