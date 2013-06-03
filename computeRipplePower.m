%------------------------------------------------------------------------------
% Usage:
%    ripplePower = computeRipplePower()
% Description:
%    Here is Eva's original comment for this code: "detect ripple power".
% Arguments:
%    rippleLfp
%       The LFP to detect the "ripple power" of
%    freqRange
%       A vector of length 2 containing the allowed range of frequencies (in
%       Hertz) for a ripple, for example `[90, 180]` to allow 90Hz to 180Hz.
% Returns:
%    ripplePower
%       .
%------------------------------------------------------------------------------
function ripplePower = computeRipplePower(rippleLfp, freqRange, sampleRate, ...
                                          smoothingFilter)
    % Some parameters that were moved here from `ripdetect_sev.m`.
    filtOrder = 500;  % filter order has to be even; .. the longer the more
                      % selective, but the operation will be linearly slower
                      % to the filter order
    filtOrder = ceil(filtOrder/2)*2;           %make sure filter order is even
    avgFiltOrder = 501; % do not change this... length of averaging filter

    % Retrieve the low- and high-band frequencies from the provided frequency
    % range.
    lowband = freqRange(1);
    highband = freqRange(2);

    % Create a band-pass filter
    firfiltb = fir1(filtOrder, [lowband / sampleRate*2, highband / sampleRate*2]);
    avgfiltb = ones(avgFiltOrder, 1) / avgFiltOrder;

    % Filter the LFP with the band-pass filter, compute its power (?), scale the
    % resultant signal (?), and smooth the scaled signal.
    rip = Filter0(firfiltb, rippleLfp); % filtering
    rip = rip.^2; % filtered * filtered >0
    rip = unity(rip);
    ripplePower = conv(rip, smoothingFilter, 'same');
end