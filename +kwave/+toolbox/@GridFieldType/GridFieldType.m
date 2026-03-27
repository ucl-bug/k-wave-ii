%% GridFieldType
% *Package:* kwave.toolbox
%
%% Description
% Enumerated type for defining different grid field types. These are used
% with the |GridField| class for size validation.
%
%% Enumeration Members
% * |ScalarField| - Scalar field the same size as the grid.
% * |VectorField| - Vector field where the first three dimensions match the
%   size of the grid, and the vector components are stored in the 4th
%   dimension.
% * |VectorX| - 1D vector oriented in the x-direction.
% * |VectorY| - 1D vector oriented in the y-direction.
% * |VectorZ| - 1D vector oriented in the z-direction.
%
%% See Also
% * |kwave.toolbox.Grid|
% * |kwave.toolbox.GridField|
% * |kwave.toolbox.GridInput|

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

classdef GridFieldType
    enumeration
        ScalarField
        VectorField
        VectorX
        VectorY
        VectorZ
    end
end
