%% setInitialConditions
% *Class:* kwave.toolbox.kWaveThermal
% *Package:* kwave.toolbox
%
% Set initial conditions.
%
%% Syntax
%   setInitialConditions(obj)
%
%% Description
% Iteratively updates the solution for the temperature field for the given
% number of time steps and time step size.
%
%% Input Arguments
% * |Nt| - (integer) Number of time steps.
% * |dt| - (numeric) Size of each time step. 

% Copyright (C) 2022- University College London.
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

function setInitialConditions(obj)

% Assign the reference diffusion coefficient if not provided. Using the
% maximum value means the scheme will be unconditionally stable when the
% medium is lossless.
if isempty(obj.medium.diffusionReference)
    diffusion = obj.medium.thermalConductivity ./ (obj.medium.density .* obj.medium.specificHeat);
    obj.medium.diffusionReference = max(diffusion, [], 'all');
end

% Initialise thermal variables.
if ~isempty(obj.source.initialTemperaturePadded)
    obj.temperaturePadded = obj.source.initialTemperaturePadded;
else
    obj.temperaturePadded = zeros(obj.kgridPadded.gridSize, obj.settings.simulationDataType);
end
