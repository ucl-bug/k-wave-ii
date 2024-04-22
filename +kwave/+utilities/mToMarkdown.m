%% mToMarkdown
% *Package:* kwave.utilities
%
% Converts a .m file associated with a function to a .md (markdown) file.
%
%% Syntax
%   mToMarkdown(inputFunctionName, outputFolder)
%
%% Description
% |mToMarkdown| takes a function name |inputFunctionName| , finds the
% corresponding .m file and converts it into a .mlx file. The .mlx file is
% then converted into a .md file and saved in the location |outputFolder|.
%
%% Input Arguments
% * |inputFunctionName| - (char) Name of input function.
% * |outputFolder| - (char) Name of output folder.

function mToMarkdown(inputFunctionName, outputFolder)

% Convert function name to full path of corresponding file
inputFunctionFullFileName = which(inputFunctionName);

% Extract file name from full path
[~, fileName, ~] = fileparts(inputFunctionFullFileName);

% Create full paths for .mlx (matlab live script) and .md (markdown) files
fullFileNameMLX  = fullfile(outputFolder, [fileName '.mlx']);
fullFileNameMD   = fullfile(outputFolder, [fileName '.md']);

% Converts the .m file into a .mlx file and saves it
matlab.internal.liveeditor.openAndSave(inputFunctionFullFileName, fullFileNameMLX);

% Exports the .mlx file into a .md file
export(fullFileNameMLX, fullFileNameMD, Format="markdown", HideCode=true);

delete(fullFileNameMLX);
