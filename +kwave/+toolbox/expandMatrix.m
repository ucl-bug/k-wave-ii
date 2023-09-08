%% expandMatrix
% *Package:* kwave.toolbox
%
% Enlarge a matrix by extending the edge values.
%
%% Syntax
%   matrixExpanded = expandMatrix(matrix, expansionSize)
%   matrixExpanded = expandMatrix(matrix, expansionSize, expansionValue)
%
%% Description
% |expandMatrix| enlarges a matrix by extension of the values at the outer
% faces (endpoints in 1D, outer edges in 2D, outer surfaces in 3D). The
% edge values are extended by |expansionSize|, which can be given as a
% scalar used by all dimension, or as a vector specifying the expansion
% size in each Cartesian direction. If an input for |expansionValue| is
% given, all expanded matrix elements will have this value.
%
%% Examples
%
%   matrix = magic(3)
%
%   matrix =
%     
%        8     1     6
%        3     5     7
%        4     9     2
%
%   kwave.toolbox.expandMatrix(matrix, 1)
%
%   ans =
%     
%        8     8     1     6     6
%        8     8     1     6     6
%        3     3     5     7     7
%        4     4     9     2     2
%        4     4     9     2     2
%
%   kwave.toolbox.expandMatrix(matrix, [2 0 1 0], 0)
%
%   ans =
%     
%        0     0     0     0
%        0     0     0     0
%        0     8     1     6
%        0     3     5     7
%        0     4     9     2
%
%% Input Arguments
% * |matrix| - (numeric) A 1D, 2D, or 3D matrix to expand.
% * |expansionSize| - (integer) The expansion size. There are several ways
%   to specify the size. If a scalar value is given, this expansion is
%   added to all sides of the matrix. In 1D, the expansion size at each end
%   can also be specified as |[xStartExp, xEndExp]|. In 2D and 3D, the
%   expansion size in each Cartesian direction can be specified as |[xExp,
%   yExp]| or |[xExp, yExp, zExp]|, or for each side in each Cartesian
%   direction as |[xStartExp, xEndExp, yStartExp, yEndExp]| or |[xStartExp,
%   xEndExp, yStartExp, yEndExp, zStartExp, zEndExp]|.
% * |expansionValue| - (numeric) Scalar value to use in the matrix
%   expansion.
%
%% Output Arguments
% * |matrixExpanded| - (numeric) Expanded matrix.

function matrixExpanded = expandMatrix(matrix, expansionSize, expansionValue)

arguments
    matrix
    expansionSize {mustBeInteger, mustBeNonnegative, mustBeNonempty}
    expansionValue {mustBeScalarOrEmpty} = []
end

if ndims(matrix) > 3
    error('expandMatrix:incorrectInputSize', 'Input matrix must be 1, 2 or 3 dimensional.');
end

% Check to see if a value for expansionValue has been given, if not, extend
% the edge values.
extendEdges = isempty(expansionValue);

% Extract the class of the input matrix.
dataType = class(matrix);

% Force the expansionValue to be logical if the matrix is logical
if islogical(matrix)
    expansionValue = logical(expansionValue);
end

if isvector(matrix) % 1D vector
    
    % Extract expansion sizes.
    if length(expansionSize) == 2
        x1Expansion = expansionSize(1);
        x2Expansion = expansionSize(2);
    elseif length(expansionSize) == 1
        x1Expansion = expansionSize(1);
        x2Expansion = expansionSize(1);
    else
        error('expandMatrix:incorrectInputSize', 'For 1D matrices, expansionSize must be given as [exp] or [xStartExp, xEndExp].');
    end
           
    % Create expanded matrix.
    xSize = length(matrix) + x1Expansion + x2Expansion;
    if isrow(matrix)
        matrixExpanded = ones(1, xSize, dataType);
    else
        matrixExpanded = ones(xSize, 1, dataType);
    end

    % Create indices to allow the original matrix to be placed into the
    % expanded matrix.
    x1 = 1 + x1Expansion;
    x2 = xSize - x2Expansion;

    % Fill expanded matrix by extending the edges, or with expansion value
    % if specified.
    if extendEdges
        matrixExpanded(1:(x1 - 1)) = matrix(1);
        matrixExpanded((x2 + 1):end) = matrix(end); 
    else
        matrixExpanded(:) = expansionValue;
    end

    % Put back original matrix inside expanded matrix.
    matrixExpanded(x1:x2) = matrix;

elseif ismatrix(matrix) % 2D matrix
    
    % Extract expansion sizes.
    if length(expansionSize) == 4
        x1Expansion = expansionSize(1);
        x2Expansion = expansionSize(2);
        y1Expansion = expansionSize(3);
        y2Expansion = expansionSize(4);
    elseif length(expansionSize) == 2
        x1Expansion = expansionSize(1);
        x2Expansion = expansionSize(1);
        y1Expansion = expansionSize(2);
        y2Expansion = expansionSize(2);    
    elseif length(expansionSize) == 1
        x1Expansion = expansionSize;
        x2Expansion = expansionSize;
        y1Expansion = expansionSize;
        y2Expansion = expansionSize;
    else
        error('expandMatrix:incorrectInputSize', 'For 2D matrices, expansionSize must be given as [exp], [xExp, yExp] or [xStartExp, xEndExp, yStartExp, yEndExp].');
    end

    % Create expanded matrix.
    xSize = size(matrix, 1) + x1Expansion + x2Expansion;
    ySize = size(matrix, 2) + y1Expansion + y2Expansion;
    matrixExpanded = ones(xSize, ySize, dataType);

    % Create indices to allow the original matrix to be placed into the
    % expanded matrix.
    x1 = 1 + x1Expansion;
    x2 = xSize - x2Expansion;
    y1 = 1 + y1Expansion;
    y2 = ySize - y2Expansion;

    % Fill expanded matrix by extending the edges, or with expansion value
    % if specified.
    if extendEdges

        % Extend edge values.
        matrixExpanded(1:x1-1, y1:y2) = repmat(matrix(1, :), x1Expansion, 1);
        matrixExpanded(x2+1:end, y1:y2) = repmat(matrix(end, :), x2Expansion, 1);
        matrixExpanded(x1:x2, 1:y1-1) = repmat(matrix(:, 1), 1, y1Expansion);
        matrixExpanded(x1:x2, y2+1:end) = repmat(matrix(:, end), 1, y2Expansion);
        
        % Extend corner values.
        matrixExpanded(1:x1-1, 1:y1-1) = matrix(1, 1) * ones(x1Expansion, y1Expansion, dataType);
        matrixExpanded(1:x1-1, y2+1:end) = matrix(1, end) * ones(x1Expansion, y2Expansion, dataType);
        matrixExpanded(x2+1:end, 1:y1-1) = matrix(end, 1) * ones(x2Expansion, y1Expansion, dataType);
        matrixExpanded(x2+1:end, y2+1:end) = matrix(end, end) * ones(x2Expansion, y2Expansion, dataType);

    else
        matrixExpanded(:) = expansionValue;
    end

    % Put back original matrix inside expanded matrix.
    matrixExpanded(x1:x2, y1:y2) = matrix;

else % 3D matrix

    % Extract expansion sizes.
    if length(expansionSize) == 6
        x1Expansion = expansionSize(1);
        x2Expansion = expansionSize(2);
        y1Expansion = expansionSize(3);
        y2Expansion = expansionSize(4);            
        z1Expansion = expansionSize(5);
        z2Expansion = expansionSize(6);
    elseif length(expansionSize) == 3
        x1Expansion = expansionSize(1);
        x2Expansion = expansionSize(1);
        y1Expansion = expansionSize(2);
        y2Expansion = expansionSize(2);              
        z1Expansion = expansionSize(3);
        z2Expansion = expansionSize(3);    
    elseif length(expansionSize) == 1
        x1Expansion = expansionSize;
        x2Expansion = expansionSize;
        y1Expansion = expansionSize;
        y2Expansion = expansionSize;            
        z1Expansion = expansionSize;
        z2Expansion = expansionSize;
    else
        error('expandMatrix:incorrectInputSize', 'For 3D matrices, expansionSize must be given as [exp], [xExp, yExp, zExp] or [xStartExp, xEndExp, yStartExp, yEndExp, zStartExp, zEndExp].');
    end

    % Create expanded matrix.
    xSize = size(matrix, 1) + x1Expansion + x2Expansion;
    ySize = size(matrix, 2) + y1Expansion + y2Expansion;
    zSize = size(matrix, 3) + z1Expansion + z2Expansion;
    matrixExpanded = ones(xSize, ySize, zSize, dataType);

    % Create indices to allow the original matrix to be placed into the
    % expanded matrix.
    x1 = 1 + x1Expansion;
    x2 = xSize - x2Expansion;
    y1 = 1 + y1Expansion;
    y2 = ySize - y2Expansion;        
    z1 = 1 + z1Expansion;
    z2 = zSize - z2Expansion;

    % Fill expanded matrix by extending the edges, or with expansion value
    % if specified.
    if extendEdges

        % Extend face values.
        matrixExpanded(1:x1-1, y1:y2, z1:z2) = repmat(matrix(1, :, :), [x1Expansion, 1, 1]);
        matrixExpanded(x2+1:end, y1:y2, z1:z2) = repmat(matrix(end, :, :), [x2Expansion, 1, 1]);
        matrixExpanded(x1:x2, 1:y1-1, z1:z2) = repmat(matrix(:, 1, :), [1, y1Expansion, 1]);
        matrixExpanded(x1:x2, y2+1:end, z1:z2) = repmat(matrix(:, end, :), [1, y2Expansion, 1]);
        matrixExpanded(x1:x2, y1:y2, 1:z1-1) = repmat(matrix(:, :, 1), [1, 1, z1Expansion]);
        matrixExpanded(x1:x2, y1:y2, z2+1:end) = repmat(matrix(:, :, end), [1, 1, z2Expansion]);            
        
        % Extend edge values.
        matrixExpanded(1:x1-1, 1:y1-1, z1:z2) = repmat(matrix(1, 1, :), [x1Expansion, y1Expansion, 1]);
        matrixExpanded(1:x1-1, y2+1:end, z1:z2) = repmat(matrix(1, end, :), [x1Expansion, y2Expansion, 1]);
        matrixExpanded(1:x1-1, y1:y2, 1:z1-1) = repmat(matrix(1, :, 1), [x1Expansion, 1, z1Expansion]);
        matrixExpanded(1:x1-1, y1:y2, z2+1:end) = repmat(matrix(1, :, end), [x1Expansion, 1, z2Expansion]);
        matrixExpanded(x2+1:end, 1:y1-1, z1:z2) = repmat(matrix(end, 1, :), [x2Expansion, y1Expansion, 1]);
        matrixExpanded(x2+1:end, y2+1:end, z1:z2) = repmat(matrix(end, end, :), [x2Expansion, y2Expansion, 1]);
        matrixExpanded(x2+1:end, y1:y2, 1:z1-1) = repmat(matrix(end, :, 1), [x2Expansion, 1, z1Expansion]);
        matrixExpanded(x2+1:end, y1:y2, z2+1:end) = repmat(matrix(end, :, end), [x2Expansion, 1, z2Expansion]);
        matrixExpanded(x1:x2, 1:y1-1, 1:z1-1) = repmat(matrix(:, 1, 1), [1, y1Expansion, z1Expansion]);
        matrixExpanded(x1:x2, y2+1:end, 1:z1-1) = repmat(matrix(:, end, 1), [1, y2Expansion, z1Expansion]);
        matrixExpanded(x1:x2, 1:y1-1, z2+1:end) = repmat(matrix(:, 1, end), [1, y1Expansion, z2Expansion]);
        matrixExpanded(x1:x2, y2+1:end, z2+1:end) = repmat(matrix(:, end, end), [1, y2Expansion, z2Expansion]);
        
        % Extend corner values.
        matrixExpanded(1:x1-1, 1:y1-1, 1:z1-1) = matrix(1, 1, 1)*ones(x1Expansion, y1Expansion, z1Expansion, dataType);
        matrixExpanded(1:x1-1, y2+1:end, 1:z1-1) = matrix(1, end, 1)*ones(x1Expansion, y2Expansion, z1Expansion, dataType);
        matrixExpanded(1:x1-1, 1:y1-1, z2+1:end) = matrix(1, 1, end)*ones(x1Expansion, y1Expansion, z2Expansion, dataType);
        matrixExpanded(1:x1-1, y2+1:end, z2+1:end) = matrix(1, end, end)*ones(x1Expansion, y2Expansion, z2Expansion, dataType);
        matrixExpanded(x2+1:end, 1:y1-1, 1:z1-1) = matrix(end, 1, 1)*ones(x2Expansion, y1Expansion, z1Expansion, dataType);
        matrixExpanded(x2+1:end, y2+1:end, 1:z1-1) = matrix(end, end, 1)*ones(x2Expansion, y2Expansion, z1Expansion, dataType);
        matrixExpanded(x2+1:end, 1:y1-1, z2+1:end) = matrix(end, 1, end)*ones(x2Expansion, y1Expansion, z2Expansion, dataType);
        matrixExpanded(x2+1:end, y2+1:end, z2+1:end) = matrix(end, end, end)*ones(x2Expansion, y2Expansion, z2Expansion, dataType);

    else
        matrixExpanded(:) = expansionValue;
    end

    % Put back original matrix inside expanded matrix.
    matrixExpanded(x1:x2, y1:y2, z1:z2) = matrix;

end
