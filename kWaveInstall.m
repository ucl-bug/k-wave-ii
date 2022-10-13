% Add k-Wave-II to the MATLAB path, and build help docs.

[toolboxPath, ~, ~] = fileparts(mfilename('fullpath'));
cd(toolboxPath);
addpath(toolboxPath);
kwave.utilities.GenerateDocumentation;
web('helpfiles/kWave.html', '-new');
