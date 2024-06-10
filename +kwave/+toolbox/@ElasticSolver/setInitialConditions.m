%% setInitialConditions
% *Class:* kwave.toolbox.ElasticSolver
% *Package:* kwave.toolbox
%
% Set initial conditions.
%
%% Syntax
%   setInitialConditions(obj)
%
%% Description
% Initialises the elastic variables |obj.pressurePadded|,
% |obj.densitySplitPadded|, and |obj.velocityPadded| to zero. The initial
% conditions for a elastic source defined by |source.initialPressure|
% are setup in |kwave.toolbox.ElasticSolver.executeTimeStep| as this
% relies on the time step size.
% 
% The reference sound speed |obj.medium.soundSpeedReference| is also
% assigned if not provided. The value is set to maximum value in
% |obj.medium.soundSpeed| which means the scheme will be unconditionally
% stable when the medium is lossless.

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

function setInitialConditions(obj)

% % Assign the reference sound speed if not provided.  Do we need it for
% PML?
% if isempty(obj.medium.soundSpeedReference)
%     obj.medium.soundSpeedReference = max(max(obj.medium.soundSpeedShear(:),obj.medium.soundSpeedCompression(:)));
% end

% Initialise elastic variables. The pressure is a scalar
% field, so has the same size as the grid. The velocity is a vector fields,
% with the Cartesian components indexed in the 4th dimension and the stress
% tensor is linearised to a vector with its components indexed in the 4th 
% dimension.
dim = obj.kgrid.dimensions;
obj.pressurePadded = zeros(obj.kgridPadded.gridSize, obj.settings.simulationDataType);
obj.velocityPadded = zeros([obj.kgridPadded.gridSize, dim], obj.settings.simulationDataType);
obj.stressPadded = zeros([obj.kgridPadded.gridSize, dim .* (dim + 1) ./ 2], obj.settings.simulationDataType);

% Assign the Lame parameters and in the future the Kelvin-Voigt model
% visco-elastic coefficients.
obj.mu     = obj.medium.soundSpeedShear.^2       .* obj.medium.density;
obj.lambda = obj.medium.soundSpeedCompression.^2 .* obj.medium.density - 2*obj.mu;
