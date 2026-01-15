%% More 1D Acoustic Solver Examples
%
%% Overview
% More 1D examples, following on from |t01_AcousticSolverExamples1D|,
% further capabilities of AcousticSolver in one-dimension.
%
% * To open the file in the MATLAB Editor:
% |edit('kwave.tutorials.initialvalueproblems.t02_MoreAcousticSolverExamples1D.m')|
% * To run the file in MATLAB:
% |run('kwave.tutorials.initialvalueproblems.t02_MoreAcousticSolverExamples1D.m')|
%
% See Also:
% * kwave.tutorials.initialvalueproblems.t01_AcousticSolverExamples1D.m
%


clearvars;             % Clear the workspace of old variables
import kwave.toolbox.* % Import the k-Wave-II toolbox

%% =========================================================================
% Define a grid

Nx = 128;     % Number of grid points
dx = 1e-3;    % Grid spacing [m]
pmlSize = 20; % Thickness of the PML (Perfectly Matched Layer absorbing boundary)
kgrid = Grid(Nx, dx, pmlSize); % Create a Grid object

%% =========================================================================
% Define heterogeneous acoustic properties, and include acoustic absorption

% Create an AcousticMedium object
medium = AcousticMedium(kgrid); 

% Define a spatially-varying sound speed (here a step change)
c0 = 1500*ones(medium.gridSize);
c0(1:end/2) = 1400;
medium.soundSpeed = c0; % [m/s]

% Define a spatially-varying ambient density (also a step change)
rho0 = 1000*ones(medium.gridSize);
rho0(1:end/2)  = 940;
medium.density = rho0;  % [kg/m^3]

% Define the acoustic absorption coefficient prefactor, the value for
% alpha0 in the expression for the absorption coefficient:
% alpha = alpha0 * f^y, where f is the frequency in MHz and y is the power
% law exponent (absorptionPower, which must be scalar).
medium.absorptionCoeff = 0.5;   % [dB/cm/MHz^y]
medium.absorptionPower = 1.9;

% Note that when using absorption, the solver must be told:
% 
% solver = AcousticSolver(kgrid,medium,source,sensor);
% solver.absorptionType='on';

%% =========================================================================
% Define an acoustic source 

% Create an AcousticSource object
source = AcousticSource(kgrid); 

% Define an initial acoustic pressure distribution
offset = floor(kgrid.Nx/4);
source.initialPressure = exp( -(kgrid.x - offset*kgrid.dx).^2 / (10*kgrid.dx^2) );

%% =========================================================================
% Define an acoustic sensor

% Create an AcousticSensor object
sensor = AcousticSensor(kgrid);

% Define a binary mask. The solver will return the field variables at the
% grid locations marked by 1 in the mask. 

sensor.mask = zeros(kgrid.gridSize);
sensor.mask(end - floor(Nx/8)) = 1;

% Record at every other timestep
sensor.timeStepSpacing = 2;

%% =========================================================================
% Run the simulation

% Create an AcousticSolver object
solver = AcousticSolver(kgrid,medium,source,sensor); 

% Turn on the absorption
solver.absorptionType='on';

% Define the CFL number and endTime allow the timestep to be chosen
% automatically 
cfl = 0.2; % CFL (Courant-Friedrichs-Lewy) number
endTime = 0.65 * kgrid.dx*kgrid.Nx / min(medium.soundSpeed(:));

% Run the solver
solver.run(CFL=cfl, EndTime=endTime);

%% =========================================================================
% The simulation output

% Plot the initial and final acoustic pressure fields
figure

subplot(3,2,1)
plot(kgrid.xVec*1e3,medium.soundSpeed)
xlabel('x [mm]')
title('Sound speed')

subplot(3,2,3)
plot(kgrid.xVec*1e3,medium.density)
xlabel('x [mm]')
title('Ambient density')

subplot(3,2,5)
stem(kgrid.xVec*1e3,sensor.mask)
xlabel('x [mm]')
title('Sensor mask')

subplot(3,2,2)
plot(kgrid.xVec*1e3,source.initialPressure)
xlabel('x [mm]')
title('Initial acoustic pressure')

subplot(3,2,4)
plot(kgrid.xVec*1e3,solver.pressure)
xlabel('x [mm]')
title('Acoustic pressure at final time')

subplot(3,2,6)
plot(sensor.times*1e6,sensor.pressure,'.-')
xlabel('time [\mus]')
title('Pressure time series recorded at sensor point')
