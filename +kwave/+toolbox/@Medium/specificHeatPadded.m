%% Specific Heat Padded
% *Class:* kwave.toolbox.Medium
% *Package:* kwave.toolbox
%
% Calls the specificHeat value across the padded spatial grid.
%
%% Syntax
%   specificHeatPadded(obj)
%
%% Description
% Recalls the specificHeat spatial distribution according to the |materialIDGrid|,
% using the generated |materialIDGridPadded|, and the given |MaterialTable| 
% from the medium.
%
% This method has been generated to allow interactions with the
% |thermalSolver|
% class, and the |thermalMedium| gridfield property |specificHeat| (|specificHeatPadded|)

% Copyright (C) 2025- The k-Wave Authors.
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


function sS=specificHeatPadded(obj)
arguments
    obj
end
if ~isscalar(obj.materialIDGridPadded)
    sS=reshape(obj.materialTable(obj.materialIDGridPadded,6),size(obj.materialIDGridPadded));
else
    sS=obj.materialTable(obj.materialIDGridPadded,6);
end
end