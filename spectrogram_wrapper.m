function [S,F,T, P]=spectrogram_wrapper(signal,SamplingFreq,Wsize,frequencies)
% [S,F,T]=spectrogram_wrapper(signal,SamplingFreq,Wsize,frequencies);
% If there are no output arguments, the spectrogramm will be displayed
% signal is the signal sampled at certain sampling frequency
% SamplingFreq is the sampling frequency in Hz
% Wsize is the size of sliding window in seconds
% frequencies is the vector of frequencies you'd like to sample your
% spectrogramm (in Hz)
% Bevare of Nyquist frequency!
% S is complex
% P is real

if nargin<4;
    frequencies= 20:10:300;
end;

if nargout>1
[S,F,T,P]=spectrogram(signal,Wsize*SamplingFreq,.25*Wsize*SamplingFreq, frequencies,SamplingFreq);
else
    spectrogram(signal,Wsize*SamplingFreq,.25*Wsize*SamplingFreq, frequencies,SamplingFreq);
end;
% possible usage "by hand"
% imagesc(T,F,P);colorbar;