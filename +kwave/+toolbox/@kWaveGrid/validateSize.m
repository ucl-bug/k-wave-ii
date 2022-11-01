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
% a |kWaveGrid| object using |validateattributes|. By default, the grid
% size not including padding is used. To include padding, set
% |IncludePadding=true|. If the input is a scalar, the check is skipped.
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
% * |FunctionName| - (char) Name of function passed to
%   |validateattributes|. Improves the verbosity of error messages. Default
%   = ''.
% * |IncludePadding| - (logical) Option to include |gridPadding| in the
%   grid size comparison. Default = false.
% * |VariableName| - (char) Name of variable passed to
%   |validateattributes|. Improves the verbosity of error messages. Default
%   = ''.

function validateSize(obj, matrix, options)

arguments
    obj
    matrix
    options.VariableName(1,:) char = ''
    options.IncludePadding(1,1) logical = false
    options.FunctionName(1,:) char = ''
end

if (numel(matrix) ~= 1)
    if (options.IncludePadding)
        validateattributes(matrix, {'numeric'}, ...
            {'size', obj.gridSize + 2 * obj.gridPadding, 'real', 'finite'}, ...
            options.FunctionName, options.VariableName);
    else
        validateattributes(matrix, {'numeric'}, ...
            {'size', obj.gridSize, 'real', 'finite'}, ...
            options.FunctionName, options.VariableName);
    end
end
