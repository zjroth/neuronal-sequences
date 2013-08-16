% Enable parallel processing
if matlabpool('size') == 0
    matlabpool('open');
end

% Ensure that this directory is the current directory.
[folder, ~, ~] = fileparts(mfilename('fullpath'));
cd(folder);

% Add the appropriate folders to the path.
addpath('./matlab-incremented');
addpath('./neural-codeware');
addpath('./matlab-cliquer');
%addpath('./comparison/')
addpath('./xmltree/');
addpath(genpath('./chronux/chronux/'))
addpath(genpath('./fma-toolbox/'))

addpath('./sequences/');
