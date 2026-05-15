%% ElasticSource
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.GridInput
%
% Class used to define the elastic sources for a simulation.
%
%% Syntax
%   source = ElasticSource(kgrid);
%
%% Description
% This class is used to define the elastic source terms. The constructor
% takes an object of the |kwave.toolbox.Grid| class which defines the grid
% size. Source matrices must match the grid size defined by kgrid.
%
%% Examples
% Define the grid and source objects, and assign the initial pressure.
%
%    kgrid = kwave.toolbox.Grid([128, 128], 1e-3);
%    source = kwave.toolbox.ElasticSource(kgrid);
%    source.initialPressure = rand(source.gridSize);
%
%% Properties
% * |initialPressure| - (numeric) Initial pressure distribution [Pa].
%% See Also
% * |GridInput|

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

classdef ElasticSource < kwave.toolbox.GridInput

    properties(Constant, Hidden=true)
        requiredProperties = {};
        gridFields = kwave.toolbox.GridField.createGridFieldsMap([
            kwave.toolbox.GridField('initialPressure', Attributes={'real', 'finite'})
        ]);
    end

end
