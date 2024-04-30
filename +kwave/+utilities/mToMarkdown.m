%% mToMarkdown
% *Package:* kwave.utilities
%
% Converts a matlab .m file associated with a function to a .md (markdown) file.
%
%% Syntax
%   mToMarkdown(inputFunctionName, outputFolder)
%
%% Description
% |mToMarkdown| takes a full filename including path |inputFunctionFullFileName|, 
% converts it into a .mlx file. The .mlx file is then converted into a .md 
% file and saved in the location |outputFolder|.
%
%% Input Arguments
% * |inputFunctionFullFileName| - (char) Full path with filename of input function
% * |outputFolder| - (char) Name of output folder.

function mToMarkdown(inputFunctionFullFileName, outputFolder)

% Extract file name from full path.
[~, fileName, ~] = fileparts(inputFunctionFullFileName);

% Create full paths for .mlx (matlab live script) and .md (markdown) files.
fullFileNameMLX  = fullfile(outputFolder, [fileName '.mlx']);
fullFileNameMD   = fullfile(outputFolder, [fileName '.md']);

% Print details of conversion to .m to .mlx.
disp(['Converting ', fileName, ' to ' [fileName '.mlx']]);

% Converts the .m file into a .mlx file and saves it.
matlab.internal.liveeditor.openAndSave(inputFunctionFullFileName, fullFileNameMLX);

% Print details of conversion to .mlx to .md.
disp(['Converting ', fileName, ' to ' [fileName '.md'] ]);

% Exports the .mlx file into a .md file.
export(fullFileNameMLX, fullFileNameMD, Format="markdown", HideCode=true);

% Deletes the intermediate .mlx file
delete(fullFileNameMLX);
