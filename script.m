filename = ['/home/s-zroth1/data/Eva-new-maze-2013/' ...
            'A543-20120422-01/A543-20120422-01'];
samplRate = 2e4;
totNch = 256;
chList = [34, 35, 46];                  % These channels are 1-indexed?

time2ms = @(m, s, ms) 60000 * m + 1000 * s + ms;
startMs = time2ms(5, 36, 200) + 32;
endMs = startMs + 2000;

%%%%%%%%%% parameters to play with %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% parameters for program flow control
plotFig = 0;

highband = 200; % bandpass filter range (180Hz to 90Hz)
lowband = 90; %
downsampleRat = 1;
samplRate = samplRate/downsampleRat;
filtOrder = 500;  % filter order has to be even; .. the longer the more
                  % selective, but the operation will be linearly slower
                  % to the filter order
avgFiltOrder = 501; % do not change this... length of averaging filter
avgFiltDelay = floor(avgFiltOrder/2);  % compensated delay period
filtOrder = ceil(filtOrder/2)*2;           %make sure filter order is even

% parameters for ripple period (ms)
min_sw_period = round(0.025*samplRate/downsampleRat) ; % minimum sharpwave period = 50ms ~ 6 cycles
max_sw_period = round(0.250*samplRate/downsampleRat); % maximum sharpwave period = 250ms ~ 30 cycles
                                                      % of ripples (max, not used now)
min_isw_period = round(0.030*samplRate/downsampleRat); % minimum inter-sharpwave period;

% threshold SD (standard deviation) for ripple detection
shpThresh_multipSD = 5;     % threshold for ripple detection
ripThresh_multipSD = 4; % the peak of the detected region must satisfy
                        % this value on top of being  supra-thresholdf.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% detection

% ZACH: Why is this check happening? The function only takes four
% arguments (and has no `varargin`).
sevFileName = [filename '.sev'];
listing = dir(sevFileName);
Nsamples = listing.bytes / (2 * totNch);

disp('Loading data for ripple detection.....');
% ZACH: This should probably be `for channel = chList` or something
% like that.
for nch = 1 : length(chList)
    syncName = ['chan'  num2str(chList(nch))];
    fidSev = fopen(sevFileName,'r');
    startRead = (chList(nch)-1)*Nsamples*2;
    % ZACH: The variable `dat` is not pre-allocated.
    dat(:, nch) = LoadSevFile(fidSev,startRead,Nsamples);
end
%dat = readmulti([filename '.dat'],totNch,chList); % from .dat
dat = downsample(dat, downsampleRat);
dat = dat(samplRate / 1000 * startMs : samplRate / 1000 * endMs, :);

% detect sharp waves based on SD-based threshold:
shp = dat(:,1)-mean(dat(:,1)) - (dat(:,3)-mean(dat(:,3)));
filtLength = 100;
sigma = 75;
gaussian_filter=1/sqrt(2*pi*sigma^2)*exp(-[0:filtLength-1].^2/(2*sigma^2));
gaussian_filter=[gaussian_filter(end:-1:2) gaussian_filter];
fShp = conv(shp, gaussian_filter, 'same');
% z-score
fShp = unity(fShp);

% detect ripple power
firfiltb = fir1(filtOrder,[lowband/samplRate*2,highband/samplRate*2]);
avgfiltb = ones(avgFiltOrder,1)/avgFiltOrder;

rip = Filter0(firfiltb,dat(:,2)); % filtering
                                  %rip = Filter0(fir_coeffs, dat(:,2));

%x = dat(:, 2);
%b = fir_coeffs; %firfiltb;
%
%    if size(x,1) == 1
%        x = x(:);
%    end
%
%    % if mod(length(b),2)~=1
%    %   error('filter order should be odd');
%    % end
%    if mod(length(b),2)~=1
%        shift = length(b)/2;
%    else
%        shift = (length(b)-1)/2;
%    end
%
%    [y0 z] = filter(b,1,x);
%
%    rip = [y0(shift+1:end,:) ; z(1:shift,:)];
%    %shift = (length(b) - mod(length(b), 2)) / 2;
%    %rip = filter(b, 1, [x; zeros(shift, 1)]);
%    %rip = rip(shift + 1 : end);

%rip = rip.^2; % filtered * filtered >0
%rip = unity(rip);
fRip = conv(unity(rip.^2), gaussian_filter, 'same');

aboveThr = (fShp > shpThresh_multipSD & fRip > ripThresh_multipSD);
[evUp evDown] = SchmittTrigger_e(aboveThr, 0.5,0.5);
