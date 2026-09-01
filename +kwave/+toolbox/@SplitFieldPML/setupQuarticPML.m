%% setupQuadraticPML
% *Package:* kwave.toolbox
% *Class:* kwave.toolbox.SplitFieldPML
%
% Setup PML on regular and staggered grid using quartic PML profile.
%
%% Syntax
%   setupQuarticPML(obj, timeStep, soundSpeed)
%
%% Description
% Sets up the PML variables on the regular and staggered grid using the
% quartic PML profile defined in <https://doi.org/10.1121/1.1421344>
% (Equation 27). The grid parameters and the PML size are obtained from the
% |kgrid| property of the |SplitFieldPML| object. The PML alpha value is
% obtained from the |pmlAlpha| property of the |SplitFieldPML| object.
%
%% Input Arguments
% * |timeStep| - (numeric) Time step [s].
% * |soundSpeed| - (numeric) Sound speed in the PML [m/s].
%
%% See Also
% * |kwave.toolbox.getQuarticPMLProfile|

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

function setupQuarticPML(obj, timeStep, soundSpeed)

arguments
    obj
    timeStep(1,1) single {mustBeReal, mustBePositive, mustBeFinite}
    soundSpeed(1,1) single {mustBeReal, mustBePositive, mustBeFinite}
end

pmlSize = obj.kgrid.gridPadding;

% X-direction PML.
obj.pmlX = obj.getQuarticPMLProfile(...
    obj.kgrid.Nx + 2 * pmlSize(1), obj.kgrid.dx, ...
    timeStep, soundSpeed, ...
    Dimension=1, PMLSize=pmlSize(1), PMLAlpha=obj.pmlAlpha(1));

obj.pmlXStaggered = obj.getQuarticPMLProfile(...
    obj.kgrid.Nx + 2 * pmlSize(1), obj.kgrid.dx, ...
    timeStep, soundSpeed, ...
    Dimension=1, PMLSize=pmlSize(1), PMLAlpha=obj.pmlAlpha(1), Staggered=true);

% Y-direction PML.
if (obj.kgrid.dimensions > 1)
    obj.pmlY = obj.getQuarticPMLProfile(...
        obj.kgrid.Ny + 2 * pmlSize(2), obj.kgrid.dy, ...
        timeStep, soundSpeed, ...
        Dimension=2, PMLSize=pmlSize(2), PMLAlpha=obj.pmlAlpha(2));

    obj.pmlYStaggered = obj.getQuarticPMLProfile(...
        obj.kgrid.Ny + 2 * pmlSize(2), obj.kgrid.dy, ...
        timeStep, soundSpeed, ...
        Dimension=2, PMLSize=pmlSize(2), PMLAlpha=obj.pmlAlpha(2), Staggered=true);
end

% Z-direction PML.
if (obj.kgrid.dimensions > 2)
    obj.pmlZ = obj.getQuarticPMLProfile(...
        obj.kgrid.Nz + 2 * pmlSize(3), obj.kgrid.dz, ...
        timeStep, soundSpeed, ...
        Dimension=3, PMLSize=pmlSize(3), PMLAlpha=obj.pmlAlpha(3));

    obj.pmlZStaggered = obj.getQuarticPMLProfile(...
        obj.kgrid.Nz + 2 * pmlSize(3), obj.kgrid.dz, ...
        timeStep, soundSpeed, ...
        Dimension=3, PMLSize=pmlSize(3), PMLAlpha=obj.pmlAlpha(3), Staggered=true);
end
