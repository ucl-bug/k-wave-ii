%% SplitFieldPML
% *Package:* kwave.toolbox
%
% Definition and application of a split field perfectly matched layer
% (PML).
%
%% Description
% Class used to define and apply a perfectly matched layer (PML) to a
% vector field. The class constructor takes a |Grid| object which defines
% the grid size. The PML size is defined by the |gridPadding| property of
% the |Grid| object.
%
% Six properties are used to store the PML on the regular and staggered
% grid in each direction. These are initialised as ones (no PML) by the
% constructor. The PML profile can be setup by calling the helper method
% |setupQuarticPML|, which sets the profiles to
% <https://doi.org/10.1121/1.1421344> (Equation 27). Alternatively, the
% individual profiles can be defined directly.
%
% The PML can be applied to a vector field |f| by calling |applyPML|. This
% applies the appropriate PML to each Cartesian direction, where the
% Cartesian components of the field are stored in the fourth dimension of
% |f|.
%
%% Input Arguments
% * |kgrid| - (kwave.toolbox.Grid) Object which defines the simulation grid
%   size.
%
%% Properties
% Input objects:
%
% * |kgrid| - (kwave.toolbox.Grid) Handle for grid object.
%
% Other properties:
%
% * |pmlX| - (single) X-direction PML on the regular grid.
% * |pmlY| - (single) Y-direction PML on the regular grid.
% * |pmlZ| - (single) Z-direction PML on the regular grid.
% * |pmlXStaggered| - (single) X-direction PML on the staggered grid.
% * |pmlYStaggered| - (single) Y-direction PML on the staggered grid.
% * |pmlZStaggered| - (single) Z-direction PML on the staggered grid.
%
%% Methods
% * |applyPML|
% * |getQuarticPMLProfile|
% * |setupQuarticPML|

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

classdef SplitFieldPML < handle

    % Properties set by constructor.
    properties(SetAccess=immutable)
        kgrid;
    end

    % Internal PML properties. These are defined to avoid property
    % initialisation order dependency, as the PML set methods access
    % another property (kgrid), which makes setting the properties order
    % dependent, and the load order cannot be guaranteed when loading an
    % object.
    properties(Access=private,Hidden=true)
        privatePmlX single {mustBeReal, mustBeFinite}
        privatePmlY single {mustBeReal, mustBeFinite}
        privatePmlZ single {mustBeReal, mustBeFinite}
        privatePmlXStaggered single {mustBeReal, mustBeFinite}
        privatePmlYStaggered single {mustBeReal, mustBeFinite}
        privatePmlZStaggered single {mustBeReal, mustBeFinite}
    end


    % PML properties.
    properties(Dependent)
        pmlX single {mustBeReal, mustBeFinite}
        pmlY single {mustBeReal, mustBeFinite}
        pmlZ single {mustBeReal, mustBeFinite}
        pmlXStaggered single {mustBeReal, mustBeFinite}
        pmlYStaggered single {mustBeReal, mustBeFinite}
        pmlZStaggered single {mustBeReal, mustBeFinite}
    end

    % Constructor.
    methods
        function obj = SplitFieldPML(kgrid)

            arguments
                kgrid(1,1) kwave.toolbox.Grid
            end
            obj.kgrid = kgrid;

            % Initialise PML properties.
            pmlSize = obj.kgrid.gridPadding;
            obj.pmlX = ones([kgrid.Nx + 2 * pmlSize(1), 1, 1], 'single');
            obj.pmlY = ones([1, kgrid.Ny + 2 * pmlSize(2), 1], 'single');
            obj.pmlZ = ones([1, 1, kgrid.Nz + 2 * pmlSize(3)], 'single');
            obj.pmlXStaggered = ones([kgrid.Nx + 2 * pmlSize(1), 1, 1], 'single');
            obj.pmlYStaggered = ones([1, kgrid.Ny + 2 * pmlSize(2), 1], 'single');
            obj.pmlZStaggered = ones([1, 1, kgrid.Nz + 2 * pmlSize(3)], 'single');

        end
    end

    % Set and get methods.
    methods

        function set.pmlX(obj, val)
            obj.kgrid.validateSize(val, VariableName='pmlX', IncludePadding=true, Type=kwave.toolbox.GridFieldType.VectorX);
            obj.privatePmlX = val;
        end

        function set.pmlXStaggered(obj, val)
            obj.kgrid.validateSize(val, VariableName='pmlXStaggered', IncludePadding=true, Type=kwave.toolbox.GridFieldType.VectorX);
            obj.privatePmlXStaggered = val;
        end

        function set.pmlY(obj, val)
            obj.kgrid.validateSize(val, VariableName='pmlY', IncludePadding=true, Type=kwave.toolbox.GridFieldType.VectorY);
            obj.privatePmlY = val;
        end

        function set.pmlYStaggered(obj, val)
            obj.kgrid.validateSize(val, VariableName='pmlYStaggered', IncludePadding=true, Type=kwave.toolbox.GridFieldType.VectorY);
            obj.privatePmlYStaggered = val;
        end

        function set.pmlZ(obj, val)
            obj.kgrid.validateSize(val, VariableName='pmlZ', IncludePadding=true, Type=kwave.toolbox.GridFieldType.VectorZ);
            obj.privatePmlZ = val;
        end

        function set.pmlZStaggered(obj, val)
            obj.kgrid.validateSize(val, VariableName='pmlZStaggered', IncludePadding=true, Type=kwave.toolbox.GridFieldType.VectorZ);
            obj.privatePmlZStaggered = val;
        end

        function pml = get.pmlX(obj)
            pml = obj.privatePmlX;
        end

        function pml = get.pmlY(obj)
            pml = obj.privatePmlY;
        end

        function pml = get.pmlZ(obj)
            pml = obj.privatePmlZ;
        end

        function pml = get.pmlXStaggered(obj)
            pml = obj.privatePmlXStaggered;
        end

        function pml = get.pmlYStaggered(obj)
            pml = obj.privatePmlYStaggered;
        end

        function pml = get.pmlZStaggered(obj)
            pml = obj.privatePmlZStaggered;
        end        

    end

    % General class methods.
    methods
        f = applyPML(obj, f);
        setupQuarticPML(obj, dt, soundSpeedReference, pmlAlpha);
    end

    methods(Static)
        profile = getQuarticPMLProfile(numGridPoints, gridSpacing, dt, soundSpeed, dimension, options);
    end

end
