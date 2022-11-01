%% assignWithGridPadding
% *Class:* kwave.toolbox.kWaveGrid
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
% |gridPadding| of the associated |kWaveGrid| object.
%
%% Input Arguments
% * |matrix| - (numeric) Matrix to pad.
% * |expansionValue| - (numeric) Value to assign within grid expansion,
%   passed to |expandMatrix|.

function matrix = assignWithGridPadding(obj, matrix, expansionValue)

arguments
    obj
    matrix
    expansionValue = []
end

if (numel(matrix) > 1) && (any(obj.gridPadding ~= 0))
    if isempty(expansionValue)
        matrix = kwave.toolbox.expandMatrix(matrix, obj.gridPadding(1:obj.dimensions));
    else
        matrix = kwave.toolbox.expandMatrix(matrix, obj.gridPadding(1:obj.dimensions), expansionValue);
    end
end
