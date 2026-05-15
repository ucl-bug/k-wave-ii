%% Parse Title
% *Package:* kwave.devtools
%
% Convenience function to extract the text appearing on the first line of
% an m-file after the characters "%% ".
%
%% Syntax
%   titleParsed = parseTitle(filename)
%
%% Description
% |parseTitle| extracts the text appearing on the first line of an m-file
% after the characters "%% ".
%
%% Input Arguments
% * |filename| - (string) Filename to get title from.
%
%% Output Arguments
% * |titleString| - (string) Extracted title.

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

function titleString = parseTitle(filename)
    fid = fopen(filename);
    titleLine = fgetl(fid);
    if any(strfind(titleLine, "%% "))
        titleString = erase(titleLine, "%% ");
    else
        error('GenerateDocumentation:missingTitleComment', '%s is missing a title comment.', filename);
    end
    fclose(fid);
end
