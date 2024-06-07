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

% Set PML variables (depend on time step).
% obj.pml.setupQuarticPML(dt, soundSpeedReference);

% Anonymous functions to simplify code within time loop.
% pml = @(x) obj.pml.applyPML(x);
% pmlSG = @(x) obj.pml.applyPML(x, Staggered=true);
gradientSymTensor = @(x) obj.gradientSymTensor(x, Staggering='forward');
gradientVector = @(x) obj.gradientVector(x, Staggering='backward');

if (obj.settings.plotSimulation)
    fig = figure;
end

% Assign pressure source to stress field.
obj.pressure = obj.kgrid.assignWithGridPadding(obj.source.initialPressure, obj.kgrid.gridPadding(1));
for dim = 1:obj.dimensions
    obj.stressPadded(:, :, :, dim) = -obj.pressure; 
end

for tIndex = 1:Nt
    %% (1) Calculate the spatial gradients of the stress field using the
    % Fourier collocation spectral method (equation (7a))
    % - In legacy this is done on the split field. 
    %
    % Options: 
    % 1. Add gradient of a tensor to @FouirerCollectons Gradient which
    % resturns the matrix of the spatial gradient of the stress field (as 
    % in equation (5) in the paper).  This was implamented as a method in
    % the @FouirerCollectons class called gradientSymTensor returning a 5D 
    % array where the last two dimensions are the stress gradient in matrix 
    % form (9 components of the split field in 3D), following the apparoach 
    % of the other spatial derivative.
    %
    % 2. Split the tensor into a number or vectors and manipulate the
    % existing divergance (non-split) operator to return the correct
    % components of the gradient of the stress tensor.  This might be
    % possible if we really want to but looks like it might be rather
    % messy so was not attempted in the initial prototype.
    %
    gradStress = gradientSymTensor(obj.stressPadded);
    %
    %% (2) Update the particle velocity using a finite difference time
    % step (equation (7b) / equation (5))
    % - In legacy this is done on the split field, adding source terms
    % then combine the split field components. This can be done with a
    % sum(A, 2) over the strain.
    %
    obj.velocityPadded = obj.velocityPadded + dt ./ obj.medium.density .* obj.sumStressComponents(gradStress);
    %
    %% (3) Calculate the spatial gradients of the updated particle
    % velocity using the Fourier collocation spectral method (equation 7c)
    % - In legacy this is done on the colocalled field.
    %
    % Extend the @FouirerCollectons class gradient to work on vector fields
    % and return a tensor. This was implamented in a similar way to the 
    % divergence method by adding a gradientVector method to the 
    % @FouirerCollectons class that returns a 5D array with the last 2 being 
    % the tensor of the velocity gradient.
    %
    gradVel = gradientVector(obj.velocityPadded);
    %
    %% (4) Calculate the spatial gradients of the time derivative of the
    % particle velocity using equation (5) - momentum conservation
    % (equation 7d)
    % - The momentum conservation is only needed when using the
    % Kelvin-Voigt model and not with the lossless model.
    %
    %% (5) Update the stress field using a finite difference time step
    % (equation (7e))
    % - In legacy this is done on the split field with 15 components in 3D.
    %
    % Options:
    % 1. Using the operators directly. 
    % This will require using the full rank stress tensors and would look
    % something like the following:
    % obj.stress = obj.stress + dt .* obj.lambda .* tr(gradVel) .* eye(dim)
    % + obj.mu .* (gradVel + gradVel.')
    %
    % 2. Using Einstein notation. 
    % Someting like for i = 1:3, j = 1:3, k = 1:3 
    % if i == k && i == j 
    % obj.stress(i) += obj.stress(i) + dt .* (lambda + 2 .* mu) .* (gradVel(:, :, :, i, j);
    % if i ~= k && if i == j 
    % ...
    % if i ~= k && if i ~= j
    % ...
    % This was implamented in computeConsisuativeEquation.m
    %
    obj.stressPadded = obj.stressPadded + dt .* obj.computeConstitutiveEquation(gradVel);
    %
    %% (6) Compute pressure from normal components of the stress
    for dim = 1:obj.dimensions
        obj.pressure = obj.pressure + obj.stressPadded(:, :, :, dim);
    end


    % Plot.
    if obj.settings.plotSimulation && (rem(tIndex, obj.settings.plotFrequency) == 0 || tIndex == 1 || tIndex == Nt)
        pressure = obj.kgrid.returnWithoutGridPadding(obj.pressure);
        figure(fig);
        obj.plotField(pressure);
    end

    obj.timeStepsTaken = obj.timeStepsTaken + 1;

end
