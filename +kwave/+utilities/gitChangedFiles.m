%% gitChangedFiles
% *Package:* kwave.utilities
%
% Return a list of files changed on current git branch.
%
%% Syntax
%   fileList = gitChangedFiles;
%   fileList = gitChangedFiles(returnAbsolutePath);
%
%% Description
% Returns a cell array of file names that have been modified between the
% current git branch and main. By default, file names are given with
% paths relative to the k-Wave root directoy. To return absolute file
% paths, call |gitChangedFiles(true)|.
%
%% Input Arguments
% * |returnAbsolutePath| - (logical) Return absolute (true) or relative
%   (false) path for modified files. Default = false. 
%
%% Output Arguments
% * |fileList| - (string) Cell array of modified files.

function fileList = gitChangedFiles(returnAbsolutePath)

arguments
    returnAbsolutePath(1,1) logical = false
end

% Get list of changed files.
[~, output] = system('git diff --diff-filter=d --name-only main');
fileList = strsplit(output, '\n');

% Remove empty cells.
fileList(cellfun('isempty', fileList)) = [];

% Compute absolute path.
if returnAbsolutePath
    fileList = fullfile(strcat([kwave.utilities.getkWavePath filesep], fileList));
end
