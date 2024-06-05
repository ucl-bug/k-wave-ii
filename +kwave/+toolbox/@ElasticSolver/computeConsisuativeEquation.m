%% computeConsisuativeEquation
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.TimeDomainSolver
%
% Computes the components of the symmetric stress tensor in linearised
% using the velocity gradient tensor and Lame parameters for the elastic
% wave propagation equation. 
%
function stress = computeConsisuativeEquation(obj, gradVel)

arguments
    obj
    gradVel(:,:,:,:,:)
end

dim = obj.dimensions;
% Preallocate output matrix (squased tensor field).
stress = zeros([dim .* (dim + 1) ./ 2, 1]);
for i = 1:dim
    for j = 1:dim
        for k = 1:dim
            if (i == k && j == i)
                stress(:, :, :, i) = stress(:, :, :, i) + (obj.lambda + 2 .* obj.mu) .* gradVel(:, :, :, i, j);
            elseif (i == j && i ~= k && j ~= k)
                stress(:, :, :, i) = stress(:, :, :, i) + obj.lamda .* gradVel(:, :, :, i, j);
            elseif (dim == 2 && i ~= k)
                stress(:, :, :, i + j + 1) = stress(:, :, :, i + j + 1) + obj.mu .* gradVel(:, :, :, i, j);
            elseif (dim == 3 && i ~= k && j ~= k)
                stress(:, :, :, i + j + 1) = stress(:, :, :, i + j + 1) + obj.mu .* gradVel(:, :, :, i, j);
            end
        end
    end
end