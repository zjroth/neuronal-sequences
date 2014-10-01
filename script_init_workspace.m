% Enable parallel processing
if license('test', 'Parallel_Toolbox') && matlabpool('size') == 0
    matlabpool('open');
end

% Ensure that this directory is the current directory.
[strRippleDir, ~, ~] = fileparts(mfilename('fullpath'));

% Add the appropriate folders to the path.
addpath(genpath('~/projects/ripple-detector/chronux_2_10/'));
addpath(genpath('~/projects/ripple-detector/fma-toolbox/'));
addpath('~/projects/matlab-incremented');

addpath(fullfile(strRippleDir, 'sequences/'));
addpath(genpath(fullfile(strRippleDir, 'figures')));

clear('strRippleDir');