%
% USAGE:
%
%    dDuration = getRecordingDuration(this)
%
% DESCRIPTION:
%
%    Retrieve the duration of the associated recording (in seconds).
%
% RETURNS:
%
%    dDuration
%
%       The requested duration (as a double-precision number)
%
function dDuration = getRecordingDuration(this)
    dDuration = length(this.Track.xMM) / sampleRate(this);
end