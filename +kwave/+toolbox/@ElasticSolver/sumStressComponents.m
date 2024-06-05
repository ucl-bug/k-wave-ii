
function stressSum =    sumStressComponents(stress, dimensions)

arguments
    stress(:,:,:,:,:)
    dimensions
end

% Preallocate output matrix (vector field).
stressSum = zeros([dimensions, 1]);
for axis = 1:dimensions
    for index = 1:dimensions
        stressSum(:, :, :, axis) = stressSum(:, :, :, axis) + stress(:, :, :, axis, index);
    end
end