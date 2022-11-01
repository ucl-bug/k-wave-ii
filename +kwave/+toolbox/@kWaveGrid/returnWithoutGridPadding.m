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

function matrix = returnWithoutGridPadding(obj, matrix)

if (numel(matrix) > 1) && (any(obj.gridPadding ~= 0))
    matrix = matrix(1 + obj.gridPadding(1):end - obj.gridPadding(1), ...
          1 + obj.gridPadding(2):end - obj.gridPadding(2), ...
          1 + obj.gridPadding(3):end - obj.gridPadding(3), :);
end
