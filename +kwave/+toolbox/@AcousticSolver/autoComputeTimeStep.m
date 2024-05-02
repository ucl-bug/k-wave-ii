%% autoComputeTimeStep
% *Class:* kwave.toolbox.AcousticSolver
% *Package:* kwave.toolbox
%
% Compute Nt and dt from CFL and EndTime.
%
%% Syntax
%   autoComputeTimeStep(obj, CFL, EndTime)
%
%% Description
% Compute the number of time steps and time step size based on the CFL
% number and the simulation end time.
%
%% Input Arguments
% * |CFL| - (numeric) Courant-Friedrichs-Lewy (CFL) number.
% * |EndTime| - (numeric) Simulation end time [s].
%
%% Output Arguments
% * |Nt| - (integer) Number of time steps.
% * |dt| - (numeric) Size of each time step.

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

function [Nt, dt] = autoComputeTimeStep(obj, CFL, endTime)

arguments
    obj
    CFL {mustBeScalarOrEmpty, mustBePositive, mustBeFinite}
    endTime {mustBeScalarOrEmpty, mustBePositive, mustBeFinite}
end

% Assign default CFL if not given.
if isempty(CFL)
    CFL = 0.3;
end

% Get the minimum and maximum sound speeds.
soundSpeedMin = min(obj.medium.soundSpeed(:));
soundSpeedMax = max(obj.medium.soundSpeed(:));

% Compute EndTime as proportional to the time to travel across the grid
% diagonal at the slowest sound speed.
if isempty(endTime)
    endTime = norm(obj.kgrid.gridSize .* obj.kgrid.gridSpacing) ./ soundSpeedMin;
end

% Compute dt based on the CFL and the maximum sound speed.
dx = min(obj.kgrid.gridSpacing(1:obj.kgrid.dimensions));
dt = CFL .* dx ./ soundSpeedMax;

% Compute Nt based on EndTime.
Nt = ceil(endTime / dt);

% Recompute dt to ensure that EndTime is exactly reached.
dt = endTime / Nt;
