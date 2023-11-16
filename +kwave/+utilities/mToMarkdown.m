function mToMarkdown(inputFunctionName, outputFolder)

% Export only supports saving from .mlx files, so we first convert the .m
% file to a .mlx file, and then convert this to a .md file.

% convert function name to filename
inputFunctionName = which(inputFunctionName);

[~, file, ~] = fileparts(inputFunctionName);
filenameMLX = fullfile(outputFolder, [file '.mlx']);
filenameMD = fullfile(outputFolder, [file '.md']);

matlab.internal.liveeditor.openAndSave(inputFunctionName, filenameMLX);

export(filenameMLX, filenameMD, Format="markdown", HideCode=true);

delete(filenameMLX);
