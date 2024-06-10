%% computeConstitutiveEquation
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.TimeDomainSolver
%
% Computes the components of the symmetric stress tensor in linearised
% using the velocity gradient tensor and Lame parameters for the elastic
% wave propagation equation. 
%
%% Syntax
% stress = computeConstitutiveEquation(obj, gradVel)
%
%% Description
% Computes the right hand side of the of the lossless elasticity
% wave propagation equation.
%
% $$\frac{\partial \sigma_{ij}}{\partial t} = \lambda \delta_{ij} \frac{\partial v_k}{x_k} + \mu\left(\frac{\partial v_i}{\partial x_j} + \frac{\partial v_j}{\partial x_i}\right) $$
%
%% Input Arguments
% |gradVel| - (numeric) The tensor field of the gradient of the
% velocity field.
%
%% Output Arguments
% |stress| - (numeric) The RHS of the lossles elastic wave propagation
% equation (consituative equation) in the format of the linearised 
% symmetric stress tensor.
%
%% See Also
% |kwave.toolbox.gradientStress|
%
function stress = computeConstitutiveEquation(obj, gradVel)

arguments
    obj
    gradVel(:,:,:,:,:)
end

dim = obj.dimensions;
% Preallocate output matrix.
stress = zeros([obj.kgridPadded.gridSize, dim .* (dim + 1) ./ 2]);
for i = 1:dim
    for j = 1:dim
        for k = 1:dim
            if (i == k && j == i)
                stress(:, :, :, k) = stress(:, :, :, k) + (obj.lambda + 2 .* obj.mu) .* gradVel(:, :, :, i, j);
            elseif (i == j && i ~= k && j ~= k)
                stress(:, :, :, k) = stress(:, :, :, k) + obj.lambda .* gradVel(:, :, :, i, j);
            elseif (dim == 2 && i ~= k)
                stress(:, :, :, i + j) = stress(:, :, :, i + j) + obj.mu .* gradVel(:, :, :, i, j);
            elseif (dim == 3 && i ~= k && j ~= k)
                stress(:, :, :, i + j + 1) = stress(:, :, :, i + j + 1) + obj.mu .* gradVel(:, :, :, i, j);
            end
        end
    end
end
