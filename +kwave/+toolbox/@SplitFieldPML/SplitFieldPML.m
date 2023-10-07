%% SplitFieldPML
% *Package:* kwave.toolbox
%
% XX.
%
%% Description
% 
%
%% Input Arguments
% * |kgrid| - (kWaveGrid) Object which defines the simulation grid size.
%
%% Properties
% Input objects:
%
% * |kgrid| - (kWaveGrid) Handle for grid object.
%
% Other properties:
%
% * |dimensions| - (double) Number of grid dimensions (1, 2, or 3).
%
%% Methods
% * |xxx|

% Copyright (C) 2023- The k-Wave Authors.
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

classdef SplitFieldPML < kwave.toolbox.kWaveInput

    % PML properties.
    properties
        pmlX single {mustBeReal, mustBeFinite}
        pmlY single {mustBeReal, mustBeFinite}
        pmlZ single {mustBeReal, mustBeFinite}
        pmlXStaggered single {mustBeReal, mustBeFinite}
        pmlYStaggered single {mustBeReal, mustBeFinite}
        pmlZStaggered single {mustBeReal, mustBeFinite}
    end

    % List of required properties.
    properties(Constant, Hidden=true)
        requiredProperties = {};
    end

    % Constructor.
    methods
        function obj = SplitFieldPML(kgrid)

            arguments
                kgrid(1,1) kwave.toolbox.kWaveGrid
            end

            % Pass input arguments to superclass constructor.
            obj@kwave.toolbox.kWaveInput(kgrid)

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
            obj.kgrid.validateSize(val, VariableName='pmlX', IncludePadding=true, Type='vector-x');
            obj.pmlX = val;
        end

        function set.pmlXStaggered(obj, val)
            obj.kgrid.validateSize(val, VariableName='pmlXStaggered', IncludePadding=true, Type='vector-x');
            obj.pmlXStaggered = val;
        end

        function set.pmlY(obj, val)
            obj.kgrid.validateSize(val, VariableName='pmlY', IncludePadding=true, Type='vector-y');
            obj.pmlY = val;
        end

        function set.pmlYStaggered(obj, val)
            obj.kgrid.validateSize(val, VariableName='pmlYStaggered', IncludePadding=true, Type='vector-y');
            obj.pmlYStaggered = val;
        end

        function set.pmlZ(obj, val)
            obj.kgrid.validateSize(val, VariableName='pmlZ', IncludePadding=true, Type='vector-z');
            obj.pmlZ = val;
        end

        function set.pmlZStaggered(obj, val)
            obj.kgrid.validateSize(val, VariableName='pmlZStaggered', IncludePadding=true, Type='vector-z');
            obj.pmlZStaggered = val;
        end        

    end    

    methods

        function f = applyPML(obj, f)
            for dimInd = 1:obj.kgrid.dimensions
                switch dimInd
                    case 1
                        f(:, :, :, 1) = obj.pmlX .* f(:, :, :, 1);
                    case 2
                        f(:, :, :, 2) = obj.pmlY .* f(:, :, :, 2);
                    case 3
                        f(:, :, :, 3) = obj.pmlZ .* f(:, :, :, 3);
                end
            end
        end

        function f = applyStaggeredPML(obj, f)
            for dimInd = 1:obj.kgrid.dimensions
                switch dimInd
                    case 1
                        f(:, :, :, 1) = obj.pmlXStaggered .* f(:, :, :, 1);
                    case 2
                        f(:, :, :, 2) = obj.pmlYStaggered .* f(:, :, :, 2);
                    case 3
                        f(:, :, :, 3) = obj.pmlZStaggered .* f(:, :, :, 3);
                end
            end
        end

        function setupQuarticPML(obj, dt, soundSpeedReference, pmlAlpha)

            arguments
                obj
                dt(1,1) single {mustBeReal, mustBeFinite}
                soundSpeedReference(1,1) single {mustBeReal, mustBeFinite}
                pmlAlpha(3,1) single {mustBeReal, mustBeFinite}
            end

            pmlSize = obj.kgrid.gridPadding;
            obj.pmlX = kwave.legacy.getPML(obj.kgrid.Nx + 2 * pmlSize(1), obj.kgrid.dx, dt, ...
                soundSpeedReference, pmlSize(1), pmlAlpha(1), false, 1);
            obj.pmlXStaggered = kwave.legacy.getPML(obj.kgrid.Nx + 2 * pmlSize(1), obj.kgrid.dx, dt, ...
                soundSpeedReference, pmlSize(1), pmlAlpha(1), true, 1);
            
            obj.pmlY = kwave.legacy.getPML(obj.kgrid.Ny + 2 * pmlSize(2), obj.kgrid.dy, dt, ...
                soundSpeedReference, pmlSize(2), pmlAlpha(2), false, 2);
            obj.pmlYStaggered = kwave.legacy.getPML(obj.kgrid.Ny + 2 * pmlSize(2), obj.kgrid.dy, dt, ...
                soundSpeedReference, pmlSize(2), pmlAlpha(2), true, 2);
            
            obj.pmlZ = kwave.legacy.getPML(obj.kgrid.Nz + 2 * pmlSize(3), obj.kgrid.dz, dt, ...
                soundSpeedReference, pmlSize(3), pmlAlpha(3), false, 3);
            obj.pmlZStaggered = kwave.legacy.getPML(obj.kgrid.Nz + 2 * pmlSize(3), obj.kgrid.dz, dt, ...
                soundSpeedReference, pmlSize(3), pmlAlpha(3), true, 3);

        end

    end


end
