% Ensure that this directory is the current directory.
[folder, ~, ~] = fileparts(mfilename('fullpath'));
cd(folder);

% Add the appropriate folders to the path.
%addpath('./comparison/')
addpath(genpath('./chronux/chronux/'))
addpath(genpath('./fma-toolbox/'))
