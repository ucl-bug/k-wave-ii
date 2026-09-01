%% returnWithoutPadding
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

% Copyright (C) 2024- The k-Wave Authors.
%
% This file is part of k-Wave-II (http://www.k-wave.org). k-Wave-II is free
% software: you can redistribute it and/or modify it under the terms of the
% GNU Lesser General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any
% later version.
%
% k-Wave-II is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
% License for more details.
%
% You should have received a copy of the GNU Lesser General Public License
% along with k-Wave-II. If not, see <http://www.gnu.org/licenses/>.

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
