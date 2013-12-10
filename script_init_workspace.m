% Enable parallel processing
if license('test', 'Parallel_Toolbox') && matlabpool('size') == 0
    matlabpool('open');
end

% Ensure that this directory is the current directory.
[strRippleDir, ~, ~] = fileparts(mfilename('fullpath'));
%cd(strRippleDir);

% Add the appropriate folders to the path.
%addpath('~/projects/neural-codeware');
%addpath('~/projects/matlab-cliquer');
%addpath('./comparison/')
%addpath('./xmltree/');
addpath(genpath('~/projects/chronux_2_10/'));
addpath(genpath('~/projects/fma-toolbox/'));
addpath('~/projects/matlab-incremented');

addpath(fullfile(strRippleDir, 'sequences/'));
addpath(genpath(fullfile(strRippleDir, 'figures')));
