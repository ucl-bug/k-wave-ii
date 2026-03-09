%% Plot Field
% *Class:* kwave.toolbox.FourierCollocation
% *Package:* kwave.toolbox
%
% Plot field.
%
%% Syntax
%   plotField(obj, f)
%
%% Description
% Plots the provided field using the plot settings defined in the
% |kwave.toolbox.Settings| object. For 1D and 2D inputs, the complete field
% is plotted using |<https://uk.mathworks.com/help/matlab/ref/plot.html plot>| 
% and |<https://uk.mathworks.com/help/matlab/ref/imagesc.html imagesc>|, 
% respectively. For 3D inputs, the three orthogonal planes
% through the origin are plotted.
%
%% Input Arguments
% * |f| - (numeric) Field to plot.

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

% Copyright (C) 2022- University College London.
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

function plotField(obj, f)

switch obj.dimensions
    case 1
        plot(obj.kgrid.xVec, f);
        xlabel('x-position [m]');
        set(gca, 'YLim', obj.settings.plotScale)
    case 2
        imagesc(obj.kgrid.yVec, obj.kgrid.xVec, f, obj.settings.plotScale);
        colormap(obj.settings.colorMap);
        ylabel('x-position [m]');
        xlabel('y-position [m]');
        axis image;
    case 3
        subplot(2, 2, 1);
        imagesc(obj.kgrid.yVec, obj.kgrid.xVec, squeeze(f(:, :, round(end/2))), obj.settings.plotScale);
        title('x-y plane (central slice)');
        axis image;
        
        subplot(2, 2, 2);
        imagesc(obj.kgrid.zVec, obj.kgrid.xVec, squeeze(f(:, round(end/2), :)), obj.settings.plotScale);
        title('x-z plane (central slice)');
        axis image;
        xlabel(['(All axes in ' 'm)']);
        
        subplot(2, 2, 3);
        imagesc(obj.kgrid.zVec, obj.kgrid.yVec, squeeze(f(round(end/2), :, :)), obj.settings.plotScale);
        title('y-z plane (central slice)');
        axis image;
        colormap(obj.settings.colorMap);
end
drawnow;
