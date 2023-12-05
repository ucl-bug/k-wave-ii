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
% a |Grid| object using <matlab:doc('validateattributes')
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

function validateSize(obj, matrix, options)

arguments
    obj
    matrix
    options.IncludePadding(1,1) logical = false
    options.Type(1,1) kwave.toolbox.GridFieldType = kwave.toolbox.GridFieldType.ScalarField
    options.VariableName(1,:) char = ''
    options.FunctionName(1,:) char = ''
end

if (numel(matrix) ~= 1)

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
            {'numeric'}, ...
            {'size', expectedGridSize}, ...
            options.FunctionName, ...
            options.VariableName);

end
