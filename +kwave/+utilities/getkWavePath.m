%% Get kWave Path
% *Package:* kwave.utilities
%
% Return the path to the root k-Wave folder.
%
%% Syntax
%   path = getkWavePath;
%
%% Description
% Returns the path to the root k-Wave folder.
%
%% Output Arguments
% * |path| - (string) Path to k-Wave.

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

function path = getkWavePath()

path = fileparts(fileparts(fileparts(mfilename('fullpath'))));
