%% assignWithGridPadding
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
% |gridPadding| of the associated |Grid| object.
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

function matrix = assignWithGridPadding(obj, matrix, expansionValue)

arguments
    obj
    matrix
    expansionValue = []
end

if (numel(matrix) > 1) && (any(obj.gridPadding ~= 0))
    matrix = kwave.toolbox.expandMatrix(matrix, obj.gridPadding(1:obj.dimensions), expansionValue);
end
