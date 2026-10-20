%% AcousticSensor
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.Sensor
%
% Class used to define acoustic sensors
%
%% Syntax
%   source = AcousticSensor(kgrid);
%
%% Description
% This class is used to define acoustic sensors. The constructor
% takes an object of the |kwave.toolbox.Sensor| class, which defines the
% grid size.
%
%% Examples
% Define the grid and sensor objects, and a binary sensor mask containing a
% single sensor position.
%
%    kgrid = kwave.toolbox.Grid([128, 128], 1e-3);
%    sensor = kwave.toolbox.AcousticSensor(kgrid);
%    sensor.pressureSensor = 'on';
%    sensor.mask = zeros(sensor.gridSize);
%    sensor.mask(1, :) = 1;
%
%    kgrid = kwave.toolbox.Grid([128, 128], 1e-3);
%    sensor = kwave.toolbox.AcousticSensor(kgrid);
%    sensor.pressureSensor = 'off';
%    sensor.velocitySensor = 'on';
%    sensor.mask = zeros(sensor.gridSize);
%    sensor.mask(1, :) = 1;
%    sensor.timeStepSpacing = 2;
%
%% Properties (pre-simulation)
% * |pressureSensor| - Sets the acoustic pressure to be recorded ('on' /
%                      'off'). Default 'on'.
% * |velocitySensor| - Sets the acoustic particle velocity to be recorded
%                      ('on' / 'off' / 'ongrid'). By default the particle
%                      velocity is returned on the staggered grid and at
%                      staggered times. The 'ongrid' option returns it on
%                      the grid (same grid as the pressure) but still at
%                      staggered times. Default 'off'.
% * |densitySensor|  - Sets the acoustic density to be recorded ('on' /
%                      'off'). Default 'off'.
% * |mask|           - Binary mask the size of the grid with 1s indicated
%                      sensor positions.
% * |timeStepSpacing| - Number of timesteps separating recording events. If
%                       this is 1 then the sensors record at every
%                       timestep. If 2 then at every other timestep, etc.
%
%% Properties (post-simulation)
%
% * |pressure| - Matrix (number of sensor points x number of time points)
%                containing the values of the acoustic pressure at the
%                sensor positions at the times given in |times|. The sensor
%                positions are indexed using Matlab's column-major indexing.
% * |velocity| - Matrix of values of the acoustic particle velocity at the
%                sensor positions at the times given in |times|.
% * |density|  - Matrix of values of the acoustic density at the sensor
%                positions at the times given in |times|.
% * |times|    - Vector of recording times.
%
%% See Also
% * |Sensor|, |GridInput|

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

classdef AcousticSensor < kwave.toolbox.Sensor

    properties
        pressureSensor char {mustBeMember( pressureSensor, {'on','off'})} = 'on'
        velocitySensor char {mustBeMember( velocitySensor, {'on','off','ongrid'})} = 'off'
        densitySensor  char {mustBeMember( densitySensor,  {'on','off'})} = 'off'

        pressure = [];
        velocity = [];
        density  = [];
        times    = [];
    end

    methods(Access=public)

        function obj = initialiseSensorData(obj, Nt, stepsTaken)
            % Allocate storage for the recording events in the next Nt
            % time steps. stepsTaken is the number of time steps the
            % solver has already taken. When it is 0, a new simulation is
            % starting, so any existing sensor data is cleared and an
            % extra recording event is allocated for the initial
            % conditions at time step 0. Otherwise the existing data is
            % extended. Recording events occur at time steps that are
            % multiples of timeStepSpacing, counted from the start of the
            % simulation.
            arguments
                obj
                Nt(1,1)         {mustBeInteger, mustBeNonnegative, mustBeFinite}
                stepsTaken(1,1) {mustBeInteger, mustBeNonnegative, mustBeFinite} = 0
            end

            Nt         = double(Nt);
            stepsTaken = double(stepsTaken);
            spacing    = double(obj.timeStepSpacing);

            if stepsTaken == 0

                % Start of a new simulation, including time step 0.
                numRecords = floor(Nt ./ spacing) + 1;
                obj.pressure    = [];
                obj.density     = [];
                obj.velocity    = [];
                obj.times       = [];
                obj.sensorIndex = 0;

            else

                % Continuation of a simulation.
                numRecords = floor((stepsTaken + Nt) ./ spacing) - floor(stepsTaken ./ spacing);

            end

            numPoints = obj.totalSensorPoints;
            if strcmp(obj.pressureSensor, 'on')
                obj.pressure = [obj.pressure, zeros(numPoints, numRecords, 'single')];
            end
            if strcmp(obj.densitySensor, 'on')
                obj.density = [obj.density, zeros(numPoints, numRecords, 'single')];
            end
            if any(strcmp(obj.velocitySensor, {'on', 'ongrid'}))
                obj.velocity = cat(3, obj.velocity, zeros(numPoints, obj.kgrid.dimensions, numRecords, 'single'));
            end
            obj.times = [obj.times, zeros(1, numRecords)];
        end

        function obj = recordSensorData(obj,solver,n)

            import kwave.toolbox.FourierCollocation

            if strcmp(obj.pressureSensor,'on')
                obj.pressure(:,n) = obj.ProcessSensorData(solver.pressure,1,'none');
            end
            if strcmp(obj.densitySensor,'on')
                obj.density(:,n) = obj.ProcessSensorData(solver.densitySplit,obj.kgrid.dimensions,'sum');
            end
            if strcmp(obj.velocitySensor,'on')
                obj.velocity(:,:,n) = obj.ProcessSensorData(solver.velocity,obj.kgrid.dimensions,'none');
            elseif strcmp(obj.velocitySensor,'ongrid')
                GridVelocityPadded = zeros(size(solver.velocityPadded));
                for dim=1:solver.kgrid.dimensions
                    GridVelocityPadded(:,:,:,dim) = stagger(solver,solver.velocityPadded(:,:,:,dim),Staggering='backward');
                end
                obj.velocity(:,:,n) = obj.ProcessSensorData(solver.kgrid.returnWithoutGridPadding(GridVelocityPadded),obj.kgrid.dimensions,'none');
            end
            obj.times(n) = solver.timePoint;
        end

    end



end
