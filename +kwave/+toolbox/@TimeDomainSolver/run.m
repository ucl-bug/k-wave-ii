%% run
% *Class:* kwave.toolbox.TimeDomainSolver
% *Package:* kwave.toolbox
%
% Iteratively update the PDE solution.
%
%% Syntax
%   run(obj)
%   run(obj, Nt=100, dt=1e-6)
%   run(obj, CFL=0.3)
%   run(obj, EndTime=100e-6)
%   run(obj, CFL=0.3, EndTime=100e-6)
%
%% Description
% Iteratively updates the PDE solution. There are four possible input
% variants:
%
% * Defining the number of time steps |Nt| and time step size |dt|.
% * Defining the Courant-Friedrichs-Lewy number |CFL|.
% * Defining the end time |EndTime|.
% * Defining both |CFL| and |EndTime|.
%
% If |Nt| and |dt| are not provided, they are automatically calculated
% using the values for |CFL| and |EndTime|. Note, the time step is always
% adjusted such that |Nt * dt = EndTime|, so the exact value for |CFL| may
% be slightly smaller than the defined value. The default values and
% calculation method for |CFL| and |EndTime| are specified within the
% |autoComputeTimeStep| method of derived classes.
%
%% Name-Value Arguments
% Specify optional pairs of arguments as |Name1=Value1,...,NameN=ValueN|,
% where |Name| is the argument name and |Value| is the corresponding value.
% Name-value arguments must appear after other arguments, but the order of
% the pairs does not matter.
%
% * |Nt| - (integer) Number of time steps.
% * |dt| - (numeric) Size of each time step.
% * |CFL| - (numeric) Courant-Friedrichs-Lewy (CFL) number.
% * |EndTime| - (numeric) Simulation time [s].

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

function run(obj, options)

arguments
    obj
    options.Nt {mustBeScalarOrEmpty, mustBeInteger, mustBeNonnegative, mustBeFinite} = []
    options.dt {mustBeScalarOrEmpty, mustBeNumeric, mustBePositive, mustBeFinite} = []
    options.CFL {mustBeScalarOrEmpty, mustBeNumeric, mustBePositive, mustBeFinite} = []
    options.EndTime {mustBeScalarOrEmpty, mustBeNumeric, mustBePositive, mustBeFinite} = []
end

kwave.utilities.mustBeAllOrNoneEmpty(options.Nt, options.dt)
if isempty(options.Nt)
    [options.Nt, options.dt] = obj.autoComputeTimeStep(options.CFL, options.EndTime);
end
options.dt=cast(options.dt,obj.settings.simulationDataType);

startTime = datetime('now');

kwave.toolbox.Logger.info(['Calling ' class(obj) '.run...']);
obj.kgrid.displayGridSize();
kwave.toolbox.Logger.info(['  dt: ' kwave.utilities.scaleSI(options.dt) 's, end time: ' kwave.utilities.scaleSI(options.dt * options.Nt) 's, time steps: ' num2str(options.Nt)]);

if (obj.timeStepsTaken==0)
    % Set initial conditions.
    obj.setInitialConditions;
    if ~isempty(obj.sensor)
        obj.sensor.initialiseSensorData(options.Nt);
    end
end


obj.executeTimeStep(options.Nt, options.dt);

elapsedTime = between(startTime, datetime('now'));
kwave.toolbox.Logger.info(['  run completed in ' kwave.utilities.formatDuration(elapsedTime)]);

% Update time variables.
obj.prevTimeStep = options.dt;
obj.timeStepsTaken = obj.timeStepsTaken + options.Nt;
if isempty(obj.timeArray)
    obj.timeArray = (0:(options.Nt)) * options.dt;
else
    obj.timeArray = [obj.timeArray, obj.timeArray(end) + (1:options.Nt) * options.dt];
end
end
