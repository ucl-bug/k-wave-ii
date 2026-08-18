%% displayGridSize
% *Class:* kwave.toolbox.Grid
% *Package:* kwave.toolbox
%
% Display grid size.
%
%% Syntax
%   displayGridSize(obj)
%
%% Description
% Displays the input and computational grid sizes using
% |kwave.toolbox.Logger.info|.

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

function displayGridSize(obj)

    printGridSize('  Input grid size: ', obj.gridSize, obj.gridSpacing, obj.dimensions);
    if any(obj.gridPadding ~= 0)
        printGridSize('  Padded grid size: ', obj.gridSize + 2 * obj.gridPadding, obj.gridSpacing, obj.dimensions);
    end

end

function printGridSize(gridString, gridSize, gridSpacing, dimensions)

    % Get suitable scaling factor.
    gridSizeMetres = gridSize .* gridSpacing;
    [~, scale, prefix] = kwave.utilities.scaleSI( min(gridSizeMetres(gridSizeMetres ~= 0)) );
    gridSizeScaled = gridSizeMetres .* scale;

    switch dimensions
        case 1
            kwave.toolbox.Logger.info([gridString ...
                num2str(gridSize(1)) ' grid points (' ...
                num2str(gridSizeScaled(1)) prefix 'm)']);
        case 2
            kwave.toolbox.Logger.info([gridString ...
                num2str(gridSize(1)) ' by ' ...
                num2str(gridSize(2)) ' grid points (' ...
                num2str(gridSizeScaled(1)) ' by ' ...
                num2str(gridSizeScaled(2)) prefix 'm)']);
        case 3
            kwave.toolbox.Logger.info([gridString ...
                num2str(gridSize(1)) ' by ' ...
                num2str(gridSize(2)) ' by ' ...
                num2str(gridSize(3)) ' grid points (' ...
                num2str(gridSizeScaled(1)) ' by ' ...
                num2str(gridSizeScaled(2)) ' by ' ...
                num2str(gridSizeScaled(3)) prefix 'm)']);
    end

end
