%% Solver
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.FourierCollocation
%
% Superclass of all kwave.toolbox solver classes.
%
%% Description
% Abstract class used to define solvers. All solvers
% classes should be derived from this class. See documentation for
% |kwave.toolbox.FourierCollocation| for details of how to compute
% derivatives.
%
% The constructor calls the |checkRequiredProperties| method for the input
% medium, source, and sensor objects. 
% 
% Classes derived from |Solver| should define padded variants of
% any PDE variables that can be accessed by the user, and implement set and
% get methods that add and remove the grid padding.
%
%% Input Arguments
% * |kgrid| - (kwave.toolbox.Grid) Object which defines the simulation grid
%   size. 
% * |medium| - (kwave.toolbox.GridInput) Object which defines the medium
%   properties. 
% * |source| - (kwave.toolbox.GridInput) Object which defines the source
%   properties. 
% * |sensor| - ...Not yet implemented...
% * |settings| - (kwave.toolbox.Settings) Object which defines the
%   simulation settings.
%
%% Properties
% Input objects:
%
% * |medium| - (kwave.toolbox.GridInput) Handle for medium object.
% * |source| - (kwave.toolbox.GridInput) Handle for source object.
% * |sensor| - ...Not yet implemented...
% * |settings| - (kwave.toolbox.Settings) Handle for settings object.
%
%% Template Methods
% * |run|
%
%% See Also
% * |kwave.toolbox.FourierCollocation|
% * |kwave.toolbox.Grid|
% * |kwave.toolbox.GridInput|
% * |kwave.toolbox.Settings|

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

classdef(Abstract) Solver < kwave.toolbox.FourierCollocation

    % Properties that can be set internally or by derived classes.
    properties(SetAccess=immutable)
        medium
        source
        sensor
        settings
    end

    % Constructor.
    methods
        function obj = Solver(kgrid, medium, source, sensor, settings)
            arguments
                kgrid(1,1) kwave.toolbox.Grid
                medium(1,1) kwave.toolbox.GridInput
                source(1,1) kwave.toolbox.GridInput
                sensor
                settings(1,1) kwave.toolbox.Settings
            end

            % Pass input arguments to superclass constructor.
            obj@kwave.toolbox.FourierCollocation(kgrid)

            % Check inputs reference the same grid object.
            if (medium.kgrid ~= kgrid)
                kwave.toolbox.Logger.error('Solver:gridMismatch', 'The medium input references a different Grid object to the kgrid input.');
            end
            if (source.kgrid ~= kgrid)
                kwave.toolbox.Logger.error('Solver:gridMismatch', 'The source input references a different Grid object to the kgrid input.');
            end

            % Check the required input properties have been defined.
            medium.checkRequiredProperties;
            source.checkRequiredProperties;

            % Assign properties.
            obj.medium = medium;
            obj.source = source;
            obj.sensor = sensor;
            obj.settings = settings;

        end
    end

    % Abstract methods.
    methods(Abstract)
        run(obj);
    end

end
