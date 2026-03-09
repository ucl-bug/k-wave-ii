%% git Changed Files
% *Package:* kwave.devtools
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
% paths relative to the k-Wave root directory. To return absolute file
% paths, call |gitChangedFiles(true)|.
%
%% Input Arguments
% * |returnAbsolutePath| - (logical) Return absolute (true) or relative
%   (false) path for modified files. Default = false. 
%
%% Output Arguments
% * |fileList| - (string) Cell array of modified files.

% Copyright (C) 2024- The k-Wave Authors.
%
% This file is part of k-Wave-II (http://www.k-wave.org). k-Wave-II is free
% software: you can redistribute it and/or modify it under the terms of the
% GNU Lesser General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any
% later version.
% 
% k-Wave-II is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
% License for more details.
% 
% You should have received a copy of the GNU Lesser General Public License
% along with k-Wave-II. If not, see <http://www.gnu.org/licenses/>.

function fileList = gitChangedFiles(returnAbsolutePath)

arguments
    returnAbsolutePath(1,1) logical = false
end

% Get list of changed files.
[status, output] = system(['git --no-pager diff --diff-filter=d ' ...
    '--name-only main']);

% Check if the Git command executed successfully
if status ~= 0
    error('SYSTEM:gitDiff', ...
        'Git diff command execution failed with status %d.', status);
end

% Parse output
fileList = strsplit(output, '\n');
fileList(cellfun('isempty', fileList)) = [];

% Compute absolute path.
if returnAbsolutePath
    fileList = fullfile(strcat([kwave.utilities.getkWavePath, ...
        filesep]), fileList);
end
