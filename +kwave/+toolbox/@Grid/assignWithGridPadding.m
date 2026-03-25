%% Assign With Grid Padding
% *Class:* kwave.toolbox.Grid
% *Package:* kwave.toolbox
%
% Pad an input matrix.
%
%% Syntax
%   matrix = assignWithGridPadding(obj, matrix)
%   matrix = assignWithGridPadding(obj, matrix, expansionValue)
%
%% Description
% Pads an input matrix using |expandMatrix| to account for the
% |gridPadding| of the associated |Grid| object. For vector fields, each
% component of the vector field is padded independently.
%
%% Input Arguments
% * |matrix| - (numeric) Matrix to pad.
% * |expansionValue| - (numeric) Value to assign within grid expansion,
%   passed to |expandMatrix|.
%
%% Output Arguments
% * |matrix| - (numeric) Padded matrix.
%
%% See Also
% * |kwave.toolbox.Grid.returnWithoutGridPadding|

function paddedMatrix = assignWithGridPadding(obj, matrix, expansionValue)

arguments
    obj
    matrix
    expansionValue = []
end

if (numel(matrix) > 1) && (any(obj.gridPadding ~= 0))

    % Preallocate padded output matrix.
    paddedSize = obj.gridSize + 2 * obj.gridPadding;
    paddedSize(4) = size(matrix, 4);
    paddedMatrix = zeros(paddedSize, 'like', matrix);

    % Expand matrix, looping over components of vector field if any.
    for ind = 1:size(matrix, 4)
        paddedMatrix(:, :, :, ind) = kwave.toolbox.expandMatrix(matrix(:, :, :, ind), obj.gridPadding(1:obj.dimensions), expansionValue);
    end
else
    paddedMatrix = matrix;
end
