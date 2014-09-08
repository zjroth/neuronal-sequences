% USAGE:
%    nSection = getSection(this, objEvent)
%
% RETURN CODES:
%    del = 1 (region-2)
%    whlL = 2 (region-1)
%    whlR = 3 (region-1)
%    armL = 4 (region-4)
%    armR = 5 (region-3)
%    armC = 6 (region-5)
%    rewL = 7 (region-7)
%    rewR = 8 (region-6)
%    rewC = 9 (region-8)
%    turnL = 10 (region-10)
%    turnR = 11 (region-9)
function nSection = getSection(this, objEvent)
    % Determine which ripple events do not overlap with any place-field event.
    vSection = getTrack(this, 'mazeSect');
    vWindow = objEvent.window * sampleRate(this);
    nSection = mode(vSection(ceil(vWindow(1)) : floor(vWindow(2))));
end
