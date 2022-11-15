%% validateSize
% *Class:* kwave.toolbox.kWaveGrid
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
% a |kWaveGrid| object using <matlab:doc('validateattributes')
% |validateattributes|>. By default, the grid size not including padding is
% used. To include padding, set |IncludePadding=true|. If the input matrix
% is a scalar, the check is skipped.
%
%% Examples
% Validate size of 2D matrix:
%
%     kgrid = kwave.toolbox.kWaveGrid([32, 32], 1e-3);
%     matrix = rand([32, 32]);
%     kgrid.validateSize(matrix);
%
% Call with optional inputs. The second call to |validateSize| will throw
% an error as the matrix doesn't match the grid size including padding.
%
%     kgrid = kwave.toolbox.kWaveGrid([32, 32], 1e-3, [10, 10]);
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
% * |VectorField| - (logical) Option check the size of a vector field
%   input, where the components of the vector field are stored in the 4th
%   input dimension. Default = false.
% * |FunctionName| - (char) Name of the calling function. Used to add
%   information to any error message thrown. Default = ''.
% * |VariableName| - (char) Name of the matrix variable. Used to add
%   information to any error message thrown. Default = ''.

function validateSize(obj, matrix, options)

arguments
    obj
    matrix
    options.IncludePadding(1,1) logical = false
    options.VectorField(1,1) logical = false
    options.VariableName(1,:) char = ''
    options.FunctionName(1,:) char = ''
end

if (numel(matrix) ~= 1)

    expectedGridSize = obj.gridSize;

    if (options.IncludePadding)
        expectedGridSize = expectedGridSize + 2 * obj.gridPadding;
    end

    if (options.VectorField)
        expectedGridSize = [expectedGridSize, obj.dimensions];
    end

    validateattributes(matrix, {'numeric'}, ...
            {'size', expectedGridSize, 'real', 'finite'}, ...
            options.FunctionName, options.VariableName);

end
