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
gradientStress = @(x) obj.gradientStree(x, Staggering='forward');
gradientVector = @(x) obj.gradientVector(x, Staggering='backward');

if (obj.settings.plotSimulation)
    fig = figure;
end

for tIndex = 1:Nt

    % (1) Calculate the spatial gradients of the stress field using the
    % Fourier collocation spectral method (equation (7a))
    % - In legacy this is done on the split field. 
    %
    % Options: 
    % 1. Add gradient of a tensor to @FouirerCollectons Gradient which
    % resturns the matrix of the spatial gradient of the stress field (as 
    % in equation (5) in the paper) in a 5D array where the last 2
    % dimensions are the matrix, following the apparoach in other spatial 
    % derivative in the @FouirerCollectons class.  Note that obj.stress
    % already has the sums and is not split into its components.
    % 
    % partialSigma = obj.gradientStress(obj.stress, Staggering='forward');
    %
    % 2. Split the tensor into a number or vectors (dim / dim for 2D, dim,
    % dim-1, dim-1, dim-1 for 3D) and add an option to select an axis for 
    % dim-1 cases. 
    %
    % ...
    %
    % (2) Update the particle velocity using a finite difference time
    % step (equation (7b) / equation (5))
    % - In legacy this is done on the split field, adding source terms
    % then combine the split field components. This can be done with a
    % sum(A, 2) over the strain.
    %
    % obj.velocity = obj.velocity + obj.dt ./ obj.medium.density .* sum(partialSigma,2);
    %
    % (3) Calculate the spatial gradients of the updated particle
    % velocity using the Fourier collocation spectral method (equation 7c)
    % - In legacy this is done on the colocalled field.
    %
    % Extend the @FouirerCollectons class gradient to work on vector fields
    % and return a tensor. This can be done in a similar way to gradient by
    % adding a gradientVector method to the @FouirerCollectons class that
    % returns a 5D array with the last 2 being the velocity gradient
    % tensor.
    % gradVel = obj.gradientVector(obj.velocity, Staggering='backwards');
    %
    % (4) Calculate the spatial gradients of the time derivative of the
    % particle velocity using equation (5) - momentum conservation
    % (equation 7d)
    % - The momentum conservation is only needed when using the
    % Kelvin-Voigt model and not with the lossless model.
    %
    % (5) Update the stress field using a finite difference time step
    % (equation (7e))
    % - In legacy this is done on the split field.
    %
    % Option 1: 
    % - using the operators directly. This will require manipulating the shape of gradVel for symmetric
    % cases so it is a dim .* ( dim + 1) ./ dim and not dim^2.
    % - In the fll rank it would be something similar to
    %
    % obj.stress = obj.stress + dt .* obj.lambda .* tr(gradVel) .* eye(dim)
    % + obj.mu .* (gradVel + gradVel.')
    % 
    %
    % Option 2: 
    % -Using i, j in Einstein notation, someting like for i = 1:3, j = 1:3,
    % k = 1:3 
    % if i == k
    % if i == j 
    % ...
    % obj.stress(i) += obj.stress(i) + dt .* (lambda + 2 .* mu) .* (gradVel(:, :, :, i, j);
    % if i ~= k
    % if i == j 
    % ...
    % if i ~= k
    % if i ~= j
    % ...
    %
    % (6) Compute pressure from normal components of the stress

    % Plot.
    % if obj.settings.plotSimulation && (rem(tIndex, obj.settings.plotFrequency) == 0 || tIndex == 1 || tIndex == Nt)
    %     figure(fig);
    %     obj.plotField(obj.pressure);
    % end

    obj.timeStepsTaken = obj.timeStepsTaken + 1;

end
