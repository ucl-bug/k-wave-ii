%% Recording Particle Velocity in Two Dimensions
%
%% Overview
% This example demonstrates how to record acoustic pressure and particle
% velocity using an AcousticSensor in a 2D initial-value problem.
%
% * To open the file in the MATLAB Editor:
% |edit('kwave.tutorials.initialvalueproblems.t05_RecordingParticleVelocity2D.m')|
% * To run the file in MATLAB:
% |run('kwave.tutorials.initialvalueproblems.t05_RecordingParticleVelocity2D.m')|
%
% See Also:
%
% * |kwave.tutorials.initialvalueproblems.t03_AcousticSolverExamples2D|
% * |kwave.tutorials.initialvalueproblems.t04_MoreAcousticSolverExamples2D|

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


%% Preliminaries
%
% This clears the workspace of any old variables
%
%   clearvars;
%
% Import the k-Wave-II toolbox
%
%   import kwave.toolbox.*

clearvars;             % Clear the workspace of old variables
import kwave.toolbox.* % Import the k-Wave-II toolbox


%% Define a 2D grid
%
%   Nx = 128;      % Number of grid points in x-direction
%   Ny = 128;      % Number of grid points in y-direction
%   dx = 1e-3;     % Grid spacing in x-direction [m]
%   dy = 1e-3;     % Grid spacing in y-direction [m]
%   pmlSizex = 20; % Thickness of the PML in the x-direction
%   pmlSizey = 20; % Thickness of the PML in the y-direction
%
% Create a Grid object
%
%   kgrid = Grid([Nx Ny], [dx dy], [pmlSizex pmlSizey]);

Nx = 128;      % Number of grid points in x-direction
Ny = 128;      % Number of grid points in y-direction
dx = 1e-3;     % Grid spacing in x-direction [m]
dy = 1e-3;     % Grid spacing in y-direction [m]
pmlSizex = 20; % Thickness of the PML in the x-direction
pmlSizey = 20; % Thickness of the PML in the y-direction

% Create a Grid object
kgrid = Grid([Nx Ny], [dx dy], [pmlSizex pmlSizey]);


%% Define the acoustic medium
%
% Create an AcousticMedium object
%
%   medium = AcousticMedium(kgrid);
%
% Define the homogeneous sound speed and ambient density
%
%   medium.soundSpeed = 1500; % [m/s]
%   medium.density = 1000;    % [kg/m^3]

medium = AcousticMedium(kgrid);

% Define the homogeneous acoustic properties
medium.soundSpeed = 1500; % [m/s]
medium.density = 1000;    % [kg/m^3]


%% Define an acoustic source
%
% Create an AcousticSource object
%
%   source = AcousticSource(kgrid);
%
% Define a small circular initial pressure distribution at the centre of
% the grid
%
%   sourceRadius = 5*kgrid.dx;
%   distanceFromCentre = hypot(kgrid.x, kgrid.y);
%   source.initialPressure = double(distanceFromCentre <= sourceRadius);

source = AcousticSource(kgrid);

% Define a small circular initial pressure distribution
sourceRadius = 5*kgrid.dx;
distanceFromCentre = hypot(kgrid.x, kgrid.y);
source.initialPressure = double(distanceFromCentre <= sourceRadius);


%% Define an acoustic sensor
%
% Create an AcousticSensor object
%
%   sensor = AcousticSensor(kgrid);
%
% Define a binary mask with point sensors above, below, left, and right of
% the source
%
%   sourceIndexX = Nx/2 + 1;
%   sourceIndexY = Ny/2 + 1;
%   sensorOffset = 24;
%   sensor.mask = zeros(kgrid.gridSize);
%   sensor.mask(sourceIndexX, sourceIndexY + sensorOffset) = 1;
%   sensor.mask(sourceIndexX, sourceIndexY - sensorOffset) = 1;
%   sensor.mask(sourceIndexX - sensorOffset, sourceIndexY) = 1;
%   sensor.mask(sourceIndexX + sensorOffset, sourceIndexY) = 1;
%
% Record acoustic pressure. Setting |velocitySensor| to |'on'| records
% particle velocity on the staggered spatial grid and at the staggered
% velocity time points, consistent with the AcousticSensor API.
%
%   sensor.pressureSensor = 'on';
%   sensor.velocitySensor = 'on';

sensor = AcousticSensor(kgrid);

% Define a binary mask with four point sensors
sourceIndexX = Nx/2 + 1;
sourceIndexY = Ny/2 + 1;
sensorOffset = 24;
sensor.mask = zeros(kgrid.gridSize);
sensor.mask(sourceIndexX, sourceIndexY + sensorOffset) = 1;
sensor.mask(sourceIndexX, sourceIndexY - sensorOffset) = 1;
sensor.mask(sourceIndexX - sensorOffset, sourceIndexY) = 1;
sensor.mask(sourceIndexX + sensorOffset, sourceIndexY) = 1;

% Record pressure
sensor.pressureSensor = 'on';

% Record velocity on the staggered spatial grid and at the staggered
% velocity time points
sensor.velocitySensor = 'on';


%% Run the simulation
%
% Create an AcousticSolver object
%
%   solver = AcousticSolver(kgrid, medium, source, sensor);
%
% Define the CFL (Courant-Friedrichs-Lewy) number and endTime to allow the
% timestep to be chosen automatically
%
%   cfl = 0.2;
%   endTime = 0.5 * kgrid.dx*kgrid.Nx / medium.soundSpeed;
%
% Run the solver
%
%   solver.run(CFL=cfl, EndTime=endTime);

solver = AcousticSolver(kgrid, medium, source, sensor);

% Define the timestep automatically
cfl = 0.2;
endTime = 0.5 * kgrid.dx*kgrid.Nx / medium.soundSpeed;

% Run the solver
solver.run(CFL=cfl, EndTime=endTime);


%% Visualisations
%
% The rows of the recorded sensor data follow MATLAB column-major mask
% ordering. For this mask, the order is below, left, right, and above.
% In 2D, |sensor.velocity(:, 1, :)| contains the x-component of particle
% velocity, while |sensor.velocity(:, 2, :)| contains the y-component.
%
%   sensorNames = {'Below', 'Left', 'Right', 'Above'};
%   [sensorIndexX, sensorIndexY] = find(sensor.mask);
%   velocityX = squeeze(sensor.velocity(:, 1, :));
%   velocityY = squeeze(sensor.velocity(:, 2, :));
%
% Plot the initial pressure distribution and sensor positions
%
%   figure
%   imagesc(kgrid.xVec*1e3, kgrid.yVec*1e3, ...
%       source.initialPressure.')
%   axis image
%   set(gca, 'YDir', 'normal')
%   colorbar
%   hold on
%   plot(kgrid.xVec(sensorIndexX)*1e3, ...
%       kgrid.yVec(sensorIndexY)*1e3, 'w+', ...
%       'MarkerSize', 10, 'LineWidth', 1.5)
%   hold off
%   xlabel('x [mm]')
%   ylabel('y [mm]')
%   title('Initial pressure and sensor positions')
%
% Plot the recorded pressure
%
%   figure
%   plot(sensor.times*1e6, sensor.pressure.')
%   xlabel('Time [\mus]')
%   ylabel('Pressure [Pa]')
%   title('Recorded pressure')
%   legend(sensorNames, 'Location', 'best')
%   grid on
%
% Plot the x-component of the recorded particle velocity
%
%   figure
%   plot(sensor.times*1e6, velocityX.')
%   xlabel('Time [\mus]')
%   ylabel('Particle velocity [m/s]')
%   title('Recorded x-component of particle velocity')
%   legend(sensorNames, 'Location', 'best')
%   grid on
%
% Plot the y-component of the recorded particle velocity
%
%   figure
%   plot(sensor.times*1e6, velocityY.')
%   xlabel('Time [\mus]')
%   ylabel('Particle velocity [m/s]')
%   title('Recorded y-component of particle velocity')
%   legend(sensorNames, 'Location', 'best')
%   grid on

sensorNames = {'Below', 'Left', 'Right', 'Above'};
[sensorIndexX, sensorIndexY] = find(sensor.mask);
velocityX = squeeze(sensor.velocity(:, 1, :));
velocityY = squeeze(sensor.velocity(:, 2, :));

figure
imagesc(kgrid.xVec*1e3, kgrid.yVec*1e3, ...
    source.initialPressure.')
axis image
set(gca, 'YDir', 'normal')
colorbar
hold on
plot(kgrid.xVec(sensorIndexX)*1e3, ...
    kgrid.yVec(sensorIndexY)*1e3, 'w+', ...
    'MarkerSize', 10, 'LineWidth', 1.5)
hold off
xlabel('x [mm]')
ylabel('y [mm]')
title('Initial pressure and sensor positions')

figure
plot(sensor.times*1e6, sensor.pressure.')
xlabel('Time [\mus]')
ylabel('Pressure [Pa]')
title('Recorded pressure')
legend(sensorNames, 'Location', 'best')
grid on

figure
plot(sensor.times*1e6, velocityX.')
xlabel('Time [\mus]')
ylabel('Particle velocity [m/s]')
title('Recorded x-component of particle velocity')
legend(sensorNames, 'Location', 'best')
grid on

figure
plot(sensor.times*1e6, velocityY.')
xlabel('Time [\mus]')
ylabel('Particle velocity [m/s]')
title('Recorded y-component of particle velocity')
legend(sensorNames, 'Location', 'best')
grid on
