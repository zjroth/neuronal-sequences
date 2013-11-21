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
    if ~isempty(this.Track)
        dDuration = length(this.Track.xMM) / sampleRate(this);
    else
        strFile = fullfile(this.cachePath, 'duration.mat');

        if exist(strFile, 'file')
            dDuration = getfield(load(strFile, 'dDuration'), 'dDuration');
        else
            stctTrack = load(this.strBehavElectrDataLFP, 'Track');
            dDuration = length(stctTrack.Track.xMM) / sampleRate(this);
            save(strFile, '-v7.3', 'dDuration');
        end
    end
end