%% sumStressComponents
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.TimeDomainSolver
%
% Sums up the components of the spatial gradient of the stress
% field.
%
%% Syntax
%   gradStressSum = sumStressComponent(obj, gradStress)
%
% Sums up the  $i$ indecies of the spatial gradient of the stress
% field in the momentum conservation equation of the elastic wave
% equation
%
% $$\frac{\partial v_i}{\partial t} = \frac{1}{\rho_0} \frac{\sigma_{ij}}{\partial x_i}$$
%
% The stress field gradient is obtained from
% kwave.toolbox.gradientStress.
%
function gradStressSum =    sumStressComponents(gradStress, dimensions)

arguments
    gradStress(:,:,:,:,:)
    dimensions
end

% Preallocate output matrix (vector field).
gradStressSum = zeros([dimensions, 1]);
for i = 1:dimensions
    for j = 1:dimensions
        gradStressSum(:, :, :, i) = gradStressSum(:, :, :, i) + gradStress(:, :, :, j, i);
    end
end
