%% executeTimeStep
% *Class:* kwave.toolbox.ElasticSolver
% *Package:* kwave.toolbox
%
% Iteratively update solution for given number of time steps.
%
%% Syntax
%   executeTimeStep(obj, Nt, dt)
%
%% Description
% Iteratively updates the solution for the elastic field for the given
% number of time steps and time step size.
%
%% Input Arguments
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

function executeTimeStep(obj, Nt, dt)

arguments
    obj
    Nt(1,1) {mustBeInteger, mustBePositive, mustBeFinite}
    dt(1,1) {mustBeNumeric, mustBePositive, mustBeFinite}
end

% Set k-space correction (depends on time step).
obj.kappa = ifftshift(kwave.toolbox.FourierCollocation.sinc(obj.medium.soundSpeedReference * obj.kgridPadded.k * dt/2));

% Set PML variables (depend on time step).
obj.pml.setupQuarticPML(dt, obj.medium.soundSpeedReference);

% Anonymous functions to simplify code within time loop.
pml = @(x) obj.pml.applyPML(x);
pmlSG = @(x) obj.pml.applyPML(x, Staggered=true);
gradient = @(x) obj.gradient(x, Staggering='forward');
divergence = @(x) obj.divergenceSplit(x, Staggering='backward');

if (obj.settings.plotSimulation)
    fig = figure;
end

for tIndex = 1:Nt

    if (obj.timeStepsTaken == 0)

        % Set initial conditions for an elastic wave initial value problem.
        % We do this here, rather than in setInitialConditions, as setting
        % the initial particle velocity requires the time step. The
        % calculated density term is automatically copied to all components
        % of densitySplit via implicit expansion.

        % obj.pressurePadded = obj.source.initialPressurePadded;
        % obj.velocityPadded = (dt ./ obj.medium.densityPadded) .* gradient(obj.pressurePadded) / 2;

    else

        % (1) Calculate the spatial gradients of the stress field using the
        % Fourier collocation spectral method (equation 7a)
        % - In legacy this is done on the split field.
        %
        % (2) Update the particle velocity using a finite difference time
        % step (equation 7b)
        % - In legacy this is done on the split field, adding source terms
        % then combine the split field components.
        %
        % (3) Calculate the spatial gradients of the updated particle
        % velocity using the Fourier collocation spectral method (equation 7c)
        % - In legacy this is done on the colocalled field.
        %
        % (4) Calculate the spatial gradients of the time derivative of the
        % particle velocity using equation (5) - momentum conservation
        % (equation 7d)
        % - The momentum conservation is only needed when using the
        % Kelvin-Voigt model and not with the lossless model.
        %
        % (5) Update the stress field using a finite difference time step
        % (equation 7e)
        % - In legacy this is done on the split field.
        %
        % Compute pressure from normal components of the stress

    end

    % Plot.
    % if obj.settings.plotSimulation && (rem(tIndex, obj.settings.plotFrequency) == 0 || tIndex == 1 || tIndex == Nt)
    %     figure(fig);
    %     obj.plotField(obj.pressure);
    % end

    obj.timeStepsTaken = obj.timeStepsTaken + 1;

end
