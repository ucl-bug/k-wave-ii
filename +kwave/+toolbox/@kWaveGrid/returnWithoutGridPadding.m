%% returnWithoutGridPadding
% *Class:* kwave.toolbox.kWaveGrid
% *Package:* kwave.toolbox
%
% Trim the padding from an output matrix.
%
%% Syntax
%   matrix = returnWithoutGridPadding(obj, matrix)
%
%% Description
% Trims the padding from an output matrix to account for the |gridPadding|
% of the associated |kWaveGrid| object.
%
%% Input Arguments
% * |matrix| - (numeric) Matrix to trim.
%
%% Output Arguments
% * |matrix| - (numeric) Trimmed matrix.
%
%% See Also
% * |kwave.toolbox.kWaveGrid.assignWithGridPadding|

function matrix = returnWithoutGridPadding(obj, matrix)

if (numel(matrix) > 1) && (any(obj.gridPadding ~= 0))

    % Check size of matrix matches padded grid size. Allow for vector
    % fields where vector components are stored in the fourth dimension.
    obj.validateSize(matrix, IncludePadding=true, VectorField=(size(matrix, 4) > 1))

    % Trim padding.
    matrix = matrix(1 + obj.gridPadding(1):end - obj.gridPadding(1), ...
          1 + obj.gridPadding(2):end - obj.gridPadding(2), ...
          1 + obj.gridPadding(3):end - obj.gridPadding(3), :);

end
