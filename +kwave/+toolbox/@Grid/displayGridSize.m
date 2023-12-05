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
% kwave.toolbox.Logger.info.

function displayGridSize(obj)

    printGridSize('  Input grid size: ', obj.gridSize, obj.gridSpacing, obj.dimensions);
    if any(obj.gridPadding ~= 0)
        printGridSize('  Padded grid size: ', obj.gridSize + obj.gridPadding, obj.gridSpacing, obj.dimensions);
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
