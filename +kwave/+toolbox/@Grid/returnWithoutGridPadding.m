%% Return Without Grid Padding
% *Class:* kwave.toolbox.Grid
% *Package:* kwave.toolbox
%
% Trim the padding from an output matrix.
%
%% Syntax
%   matrix = returnWithoutGridPadding(obj, matrix)
%
%% Description
% Trims the padding from an output matrix to account for the |gridPadding|
% of the associated |Grid| object.
%
%% Input Arguments
% * |matrix| - (numeric) Matrix to trim.
%
%% Output Arguments
% * |matrix| - (numeric) Trimmed matrix.
%
%% See Also
% * |kwave.toolbox.Grid.assignWithGridPadding|

function matrix = returnWithoutGridPadding(obj, matrix)

arguments
    obj
    matrix
end

if (numel(matrix) > 1) && (any(obj.gridPadding ~= 0))

    % Check size of matrix matches padded grid size. Allow for vector
    % fields where vector components are stored in the fourth dimension.
    if (size(matrix, 4) > 1)
        type = kwave.toolbox.GridFieldType.VectorField;
    else
        type = kwave.toolbox.GridFieldType.ScalarField;
    end
    obj.validateSize(matrix, IncludePadding=true, Type=type);

    % Trim padding.
    matrix = matrix(1 + obj.gridPadding(1):end - obj.gridPadding(1), ...
          1 + obj.gridPadding(2):end - obj.gridPadding(2), ...
          1 + obj.gridPadding(3):end - obj.gridPadding(3), :);

end
