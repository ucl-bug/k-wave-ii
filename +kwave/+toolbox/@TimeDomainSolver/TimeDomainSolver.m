%% TimeDomainSolver
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.Solver
%
% Superclass of all kwave.toolbox time domain solver classes.
%
%% Description
% Abstract class used to define time-domain solvers. Time domain solvers
% classes should be derived from this class. See documentation for
% |kwave.toolbox.Solver| for further details.
%
% The constructor calls the |kwave.toolbox.Solver| with the input objects.
% It also calls the |setInitialConditions| method. The default
% implementation for |setInitialConditions| is blank, and derived classes
% should reimplement this as appropriate to initialise variables used in
% the time loop.
%
% Derived classes must provide a concrete implementation of the protected
% |executeTimeStep| method which implements the numerical solution to the
% PDE. |executeTimeStep| is called by the public |run| method which
% also prints simulation information using |kwave.toolbox.Logger.info|.
%
% Classes derived from |TimeDomainSolver| should define padded variants of
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
% * |prevTimeStep| - (single) Size of the time step used in the last call
%   to |run|. Set to an empty array if |run| hasn't been called.
% * |timeArray| - (single) Time points at which update steps were taken.
% * |timeStepsTaken| - (integer) Number of time steps taken.
%
%% Methods
% * |run|
%
%% See Also
% * |kwave.toolbox.Solver|
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

classdef(Abstract) TimeDomainSolver < kwave.toolbox.Solver

    properties(SetAccess=protected)
        prevTimeStep single {mustBeScalarOrEmpty} = []
        timeArray single = []
        timeStepsTaken(1,1) uint64 = 0
    end

    % Constructor.
    methods
        function obj = TimeDomainSolver(kgrid, medium, source, sensor, settings)
            arguments
                kgrid(1,1) kwave.toolbox.Grid
                medium(1,1) kwave.toolbox.GridInput
                source(1,1) kwave.toolbox.GridInput
                sensor
                settings(1,1) kwave.toolbox.Settings
            end

            % Pass input arguments to superclass constructor.
            obj@kwave.toolbox.Solver(kgrid, medium, source, sensor, settings)

            

        end
    end

    % Abstract methods that must be implemented by sub-classes.
    methods(Abstract, Access=protected)
        executeTimeStep(obj, Nt, dt);
        [Nt, dt] = autoComputeTimeStep(obj, CFL, endTime);
    end

    % General class methods with a concrete implementation.
    methods
        run(obj);
    end

    % Internal class methods with an empty implementation. These can
    % optionally be implemented by sub-classes.
    methods(Access=protected)
        function setInitialConditions(~)
        end
    end

end
