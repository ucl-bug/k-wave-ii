%% takeTimeStep
% *Class:* kwave.toolbox.kWaveThermal
% *Package:* kwave.toolbox
%
% Iteratively update solution for given number of time steps.
%
%% Syntax
%   takeTimeStep(obj, Nt, dt)
%
%% Description
% Iteratively updates the solution for the temperature field for the given
% number of time steps and time step size. This function implements the
% pseudospectral time domain solution to the governing PDE.
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

function takeTimeStep(obj, Nt, dt)

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
if (obj.timeStepsTaken == 0)
    tStartIndex = 2;
else
    tStartIndex = 1;
end

% Iteratively update solution.
for tIndex = tStartIndex:Nt

    % Calculate temperature field. 
    obj.temperaturePadded = obj.temperaturePadded + ...
        dt ./ (obj.medium.densityPadded .* obj.medium.specificHeatPadded) .* ...
        obj.divergence(obj.medium.thermalConductivityPadded .* obj.gradient(obj.temperaturePadded));

    % Plot field.
    if obj.settings.plotSimulation && (rem(tIndex, obj.settings.plotFrequency) == 0 || tIndex == tStartIndex || tIndex == Nt)
        obj.plotField(obj.temperature);
    end

end

% Update time axes.
obj.timeStepsTaken = obj.timeStepsTaken + Nt;
if isempty(obj.timeArray)
    obj.timeArray = (0:(Nt - 1)) * dt;
else
    obj.timeArray = [obj.timeArray, obj.timeArray(end) + (1:Nt) * dt];
end
