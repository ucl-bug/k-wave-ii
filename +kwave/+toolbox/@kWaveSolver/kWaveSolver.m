%% kWaveSolver
% *Package:* kwave.toolbox
%
% Superclass of all kwave.toolbox solver classes.
%
%% Description
% Abstract class used to define time-domain solvers. Solvers classes should
% be derived from this class. Derived classes must provide a concrete
% implementation of
% * |takeTimeStep|
% * |setInitialConditions|
%
% They must also define padded variants of PDE variables that can
% be accessed by the user, and implement set and get methods that add and
% remove the grid padding. See the |kWaveInput| documentation for further
% details.
%
% Methods are provided for calculating the gradient and divergence, along
% with support for the k-space dispersion correction when the property
% |kappa| is set.
%
%% Abstract methods
% |takeTimeStep|
%
% Implements the numerical solution to the PDE. Must also update the
% |timeStepsTaken| and |tArray| properties.
%
% |setInitialConditions|
%
% Initialises variables used in the time loop.
%
%% Input Arguments
% * |kgrid| - (kWaveGrid) Object which defines the simulation grid size.
% * |medium| - (kWaveInput) Object which defines the medium properties.
% * |source| - (kWaveInput) Object which defines the source properties.
% * |sensor| - ...Not yet implemented...
% * |settings| - (kWaveSettings) Object which defines the simulation
%   settings.
%
%% Properties
% Input objects:
%
% * |kgrid| - (kWaveGrid) Handle for grid object.
% * |medium| - (kWaveInput) Handle for medium object.
% * |source| - (kWaveInput) Handle for source object.
% * |sensor| - ...Not yet implemented...
% * |settings| - (kWaveSettings) Handle for settings object.
%
% Other properties:
%
% * |dimensions| - (double) Number of grid dimensions (1, 2, or 3).
% * |timeArray| - (double) Time points at which update steps were taken.
% * |timeStepsTaken| - (integer) Number of time steps taken.
%
%% Methods
% * |divergence|
% * |divergenceSplit|
% * |gradient|
% * |plotField|
% * |sinc|

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

classdef(Abstract) kWaveSolver < handle

    properties(SetAccess=immutable)
        dimensions
        kgrid
        medium
        source
        sensor
        settings
    end

    properties(SetAccess=immutable, Hidden=true)
        kgridPadded kwave.toolbox.kWaveGrid
    end

    % Internal 1D derivative operators defined with no staggering, forward
    % staggering, and backward staggering. These are computed in the
    % constructor and stored to save compute time during derivative
    % calculations.
    properties(SetAccess=immutable, GetAccess=private, Hidden=true)
        ddxNoShift single
        ddyNoShift single
        ddzNoShift single

        ddxShiftPos single
        ddyShiftPos single
        ddzShiftPos single

        ddxShiftNeg single
        ddyShiftNeg single
        ddzShiftNeg single
    end

    properties(SetAccess=protected)
        timeStepsTaken uint64 = 0
        timeArray single
    end

    properties(Access=protected, Hidden=true)
        kappa single
    end

    % Constructor.
    methods
        function obj = kWaveSolver(kgrid, medium, source, sensor, settings)
            arguments
                kgrid(1,1) kwave.toolbox.kWaveGrid
                medium(1,1) kwave.toolbox.kWaveInput
                source(1,1) kwave.toolbox.kWaveInput
                sensor
                settings(1,1) kwave.toolbox.kWaveSettings = kwave.toolbox.kWaveSettings
            end

            % Check inputs reference the same grid object.
            if (medium.kgrid ~= kgrid)
                error('kWaveSolver:gridMismatch', 'The medium input references a different kWaveGrid object to the kgrid input.');
            end
            if (source.kgrid ~= kgrid)
                error('kWaveSolver:gridMismatch', 'The source input references a different kWaveGrid object to the kgrid input.');
            end

            % Check the required input properties have been defined.
            medium.checkRequiredProperties;
            source.checkRequiredProperties;

            % Assign properties.
            obj.dimensions = kgrid.dimensions;
            obj.medium = medium;
            obj.source = source;
            obj.sensor = sensor;
            obj.settings = settings;

            % Assign grid and expanded grid.
            obj.kgrid = kgrid;
            obj.kgridPadded = kwave.toolbox.kWaveGrid(kgrid.gridSize(1:kgrid.dimensions) + 2 * kgrid.gridPadding(1:kgrid.dimensions), kgrid.gridSpacing(1:kgrid.dimensions));

            % Assign derivative operators.
            obj.ddxNoShift = reshape(ifftshift(-1i * obj.kgridPadded.kxVec), [], 1, 1);
            obj.ddyNoShift = reshape(ifftshift(-1i * obj.kgridPadded.kyVec), 1, [], 1);
            obj.ddzNoShift = reshape(ifftshift(-1i * obj.kgridPadded.kzVec), 1, 1, []);
            
            obj.ddxShiftPos = reshape(ifftshift(-1i * obj.kgridPadded.kxVec .* exp( 1i.*obj.kgridPadded.kxVec * obj.kgridPadded.dx/2)), [], 1, 1);
            obj.ddyShiftPos = reshape(ifftshift(-1i * obj.kgridPadded.kyVec .* exp( 1i.*obj.kgridPadded.kyVec * obj.kgridPadded.dy/2)), 1, [], 1);
            obj.ddzShiftPos = reshape(ifftshift(-1i * obj.kgridPadded.kzVec .* exp( 1i.*obj.kgridPadded.kzVec * obj.kgridPadded.dz/2)), 1, 1, []);

            obj.ddxShiftNeg = reshape(ifftshift(-1i * obj.kgridPadded.kxVec .* exp(-1i.*obj.kgridPadded.kxVec * obj.kgridPadded.dx/2)), [], 1, 1);
            obj.ddyShiftNeg = reshape(ifftshift(-1i * obj.kgridPadded.kyVec .* exp(-1i.*obj.kgridPadded.kyVec * obj.kgridPadded.dy/2)), 1, [], 1);
            obj.ddzShiftNeg = reshape(ifftshift(-1i * obj.kgridPadded.kzVec .* exp(-1i.*obj.kgridPadded.kzVec * obj.kgridPadded.dz/2)), 1, 1, []);

            % Set initial conditions (sub-classes must have a concrete
            % implementation of abstract method).
            obj.setInitialConditions;

        end
    end

    % Set and get methods.
    methods
        function set.kappa(obj, val)
            if numel(val) == 1
                obj.kappa = val;
            else
                obj.kgrid.validateSize(val, IncludePadding=true, VariableName='kappa'); %#ok<MCSUP> 
                obj.kappa = val;
            end
        end
    end

    % General class methods with a concrete implementation.
    methods
        f = divergence(obj, f, varargin);
        f = divergenceSplit(obj, f, options)
        out = gradient(obj, f, options);
        plotField(obj, f);
    end

    % Static class methods with a concrete implementation.
    methods(Static)
        y = sinc(x);
    end

    % Abstract methods that must be implemented by sub-classes.
    methods(Abstract)
        takeTimeStep(obj, Nt, dt);
    end

    % Internal class methods with an empty implementation. These can
    % optionally be implemented by sub-classes.
    methods(Access=protected)
        function setInitialConditions(~)
        end
    end

end
