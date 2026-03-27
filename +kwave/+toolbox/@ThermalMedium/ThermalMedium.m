%% ThermalMedium
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.GridInput
%
% Class used to define the thermal medium properties for a simulation.
%
%% Syntax
%   kgrid = Grid([128, 128], 1e-3);
%   medium = ThermalMedium(kgrid);
%   medium.density = rand(medium.gridSize);
%
%% Description
% This class is used to define the thermal medium properties. The
% constructor takes an object of the |kwave.toolbox.Grid| class which
% defines the grid size. All medium properties can be scalar or have the
% same size as the grid. The |density|, |specificHeat|, and
% |thermalConductivity| must be defined.
%
%% Examples
% Define the grid and medium objects, and assign the thermal properties.
%
%    kgrid = kwave.toolbox.Grid([128, 128], 1e-3);
%    medium = kwave.toolbox.ThermalMedium(kgrid);
%    medium.density = rand(medium.gridSize);
%    medium.specificHeat = rand(medium.gridSize);
%    medium.thermalConductivity = rand(medium.gridSize);
%
%% Properties
% * |density| - (numeric) Mass density [kg/m^2].
% * |diffusionReference| - (numeric) Reference diffusion coefficient used
%   in the k-space correction term [m^2/s]. Automatically defined in
%   ThermalSolver if not defined by the user.
% * |specificHeat| - (numeric) Specific heat capacity at constant pressure
%   [J/kg/K].
% * |thermalConductivity| - (numeric) Thermal conductivity [W/m/K].
%
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

classdef ThermalMedium < kwave.toolbox.GridInput

    properties
        diffusionReference {mustBeReal, mustBeFinite}
    end

    properties(Constant, Hidden=true)
        requiredProperties = {'density', 'specificHeat', 'thermalConductivity'};
        gridFields = kwave.toolbox.GridField.createGridFieldsMap([
            kwave.toolbox.GridField('density');
            kwave.toolbox.GridField('specificHeat');
            kwave.toolbox.GridField('thermalConductivity')
        ]);
    end

end
