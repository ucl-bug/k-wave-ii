%% executeTimeStep
% *Class:* kwave.toolbox.ThermalSolver
% *Package:* kwave.toolbox
%
% Iteratively update solution for given number of time steps.
%
%% Syntax
%   executeTimeStep(obj, Nt, dt)
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

function executeTimeStep(obj, Nt, dt)

arguments
    obj
    Nt(1,1) {mustBeInteger, mustBePositive, mustBeFinite}
    dt(1,1) {mustBeNumeric, mustBePositive, mustBeFinite}
end

% Set k-space correction (depends on time step).
kappa = dt .* obj.medium.diffusionReference .* obj.kgridPadded.k.^2;
kappa = (1 - exp(-kappa) ) ./ kappa;
kappa(obj.kgridPadded.k == 0) = 1;
obj.kappa = ifftshift(sqrt(kappa));

% Do nothing for the first time-step so the solution at t = 0 is equal
% to the initial condition.
if Nt ~= 0
    % Iteratively update solution.
    for tIndex = 1:Nt

        % Calculate temperature field.
        obj.temperaturePadded = obj.temperaturePadded + ...
            dt ./ (obj.medium.densityPadded .* obj.medium.specificHeatPadded) .* ...
            obj.divergence(obj.medium.thermalConductivityPadded .* obj.gradient(obj.temperaturePadded));

        % Plot field.
        if obj.settings.plotSimulation && (rem(tIndex, obj.settings.plotFrequency) == 0 || tIndex == 1 || tIndex == Nt)
            obj.plotField(obj.temperature);
        end

    end
end

end
