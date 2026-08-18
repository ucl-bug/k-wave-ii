%% validateSize
% *Class:* kwave.toolbox.Grid
% *Package:* kwave.toolbox
%
% Check if matrix matches grid size.
%
%% Syntax
%   validateSize(obj, matrix)
%   validateSize(obj, matrix, options)
%
%% Description
% Checks if the size of an input matrix matches the |gridSize| property of
% a |Grid| object using <https://uk.mathworks.com/help/matlab/ref/validateattributes.html
% |validateattributes|>. By default, the grid size not including padding is
% used. To include padding, set |IncludePadding=true|. If the input matrix
% is a scalar, the check is skipped.
%
%% Examples
% Validate size of 2D matrix:
%
%     kgrid = kwave.toolbox.Grid([32, 32], 1e-3);
%     matrix = rand([32, 32]);
%     kgrid.validateSize(matrix);
%
% Call with optional inputs. The second call to |validateSize| will throw
% an error as the matrix doesn't match the grid size including padding.
%
%     kgrid = kwave.toolbox.Grid([32, 32], 1e-3, [10, 10]);
%     matrix = rand([32, 32]);
%     kgrid.validateSize(matrix, VariableName='myInput');
%     kgrid.validateSize(matrix, VariableName='myInput', IncludePadding=true);
%
%% Input Arguments
% * |matrix| - (numeric) Matrix to check size of. Must be real and finite.
%
%% Name-Value Arguments
% Specify optional pairs of arguments as |Name1=Value1,...,NameN=ValueN|,
% where |Name| is the argument name and |Value| is the corresponding value.
% Name-value arguments must appear after other arguments, but the order of
% the pairs does not matter.
%
% * |IncludePadding| - (logical) Option to include |gridPadding| in the
%   grid size comparison. Default = false.
% * |Type| - (kwave.toolbox.GridFieldType) Type of grid variable. For
%   vector fields, the components of the vector field are stored in the 4th
%   input dimension. Default = kwave.toolbox.GridFieldType.ScalarField.
% * |FunctionName| - (char) Name of the calling function. Used to add
%   information to any error message thrown. Default = ''.
% * |VariableName| - (char) Name of the matrix variable. Used to add
%   information to any error message thrown. Default = ''.

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

function validateSize(obj, matrix, options)

arguments
    obj
    matrix
    options.IncludePadding(1,1) logical = false
    options.Type(1,1) kwave.toolbox.GridFieldType = kwave.toolbox.GridFieldType.ScalarField
    options.VariableName(1,:) char = ''
    options.FunctionName(1,:) char = ''
end

if isscalar(matrix)
    return
end

expectedGridSize = obj.gridSize;

if (options.IncludePadding)
    expectedGridSize = expectedGridSize + 2 * obj.gridPadding;
end

switch (options.Type)
    case kwave.toolbox.GridFieldType.VectorField
        expectedGridSize = [expectedGridSize, obj.dimensions];
    case kwave.toolbox.GridFieldType.VectorX
        expectedGridSize([2, 3]) = 1;
    case kwave.toolbox.GridFieldType.VectorY
        expectedGridSize([1, 3]) = 1;
    case kwave.toolbox.GridFieldType.VectorZ
        expectedGridSize([1, 2]) = 1;
end

validateattributes(matrix, ...
    {'numeric','logical'}, ...
    {'size', expectedGridSize}, ...
    options.FunctionName, ...
    options.VariableName);
