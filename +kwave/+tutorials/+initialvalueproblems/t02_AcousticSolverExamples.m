%% Acoustic Solver example
%
%% Overview
% This example demonstrates how to construct and run a variety of simple
% problems using the acoustic solver in k-Wave II. From constructing the
% grid, building the Acooustic Medium, setting initial conditions and
% running the code.
%
% * To open the file in the MATLAB Editor:
% |edit('kwave.tutorials.initialvalueproblems.AcousticSolverExamples')|
% * To run the file in MATLAB:
% |run('kwave.tutorials.initialvalueproblems.AcousticSolverExamples.m')|
%
% Within this example are commented alternative versions, marked by
% indents. These can be uncommented or commented out respectively.
% This Example is broken down into the following Sections.
% * Setup
% * Running the AcousticSolver and outputs
% * Including absorption
% * Including a sensor
%
% See Also:
% * kwave.tutorials.initialvalueproblems.homogeneousMedium2D
%

%% Setup
% 
% AcousticSolver takes four main inputs:
% * Grid
% * Medium
% * Source
% * Sensor (optional)
%
% First import the toolbox.

    clearvars;
    import kwave.toolbox.*

% =========================================================================
%% Defining the grid

% Now create a grid object by calling the Grid function. This contains all
% the details of the computational grid. The inputs for Grid are:
% * The number of grid points
% * The distance between grid points in meters [m]
% * Size of the PML (optional)
% Example A uses a 1D domain without a PML
% Example B uses a 2D domain with different grid spacing in each dimension.
% Example C uses a 3D domain with isotropic grid spacing.
% Example D uses a 2D domain with a PML only in the y direction.
% Example E uses a 3D domain with a PML of the same size in each dimension.

    % A)
    Nx = 128;             % Number of grid points
    dx = 1e-3;            % Grid spacing [m]
    kgrid = Grid(Nx, dx); % Construct the grid

    % B)
    % Nx = 128;                       % Number of x grid points in
    % Ny = 54;                        % Number of y grid points
    % dx = 1e-3;                      % Grid spacing in x dimension [m]
    % dy = 5e-4;                      % Grid spacing in y dimension [m]
    % kgrid = Grid([Nx,Ny], [dx,dy]); % Construct the grid

    % C)
    % Nx = 128;                       % Number of x grid points
    % Ny = 54;                        % Number of y grid points
    % Nz = 129;                       % Number of z grid points
    % dx = 1e-3;                      % Grid spacing [m]
    % kgrid = Grid([Nx,Ny, Nz], dx);  % Construct the grid.
    
    % D)
    % Nx = 128;                                % Number of x grid points
    % Ny = 128;                                % Number of y grid points
    % dx = 1e-3;                               % Grid spacing [m]
    % PMLx = 0;                                % Number of grid points either side of the domain for the PML in the x direction
    % PMLy = 20;                               % Number of grid points either side of the domain for the PML in the y direction
    % kgrid = Grid([Nx, Ny], dx, [PMLx,PMLy]); % Construct the grid

    % E)
    % Nx = 128;                              % Number of x grid points
    % Ny = 54;                               % Number of y grid points
    % Nz = 129;                              % Number of z grid points
    % dx = 1e-3;                             % Grid spacing [m]
    % PMLsize = 0;                           % Number of grid points either side of the domain for the PML
    % kgrid = Grid([Nx,Ny,Nz], dx, PMLsize); % Construct the grid

% =========================================================================
%% Defining the medium

% Next, we require Medium. In k-wave-II's AcousticSolver the medium can be
% constructed in two ways: through the AcousticMedium class, or through the
% Medium class. We will cover the just former case in this example. The
% Acoustic Medium Class is constructed by calling it with the grid.

    medium = AcousticMedium(kgrid);

% In order to run the AcousticSolver, at least two medium properties must
% be defined: sound speed and ambient density. These can either be 
% constant across the domain (homogeneous medium) or defined on the grid. 

    c0   = 1500; % sound speed [m/s]
    rho0 = 1000; % ambient density [kg/m^3]
    
    medium.soundSpeed = c0;   % Sets a constant sound speed
    medium.density    = rho0; % Sets a constant density

    % medium.soundSpeed         = ones(kgrid.gridSize)*c0;
    % medium.soundSpeed(1:52,:) = 1.1*c0;
    % medium.density            = ones(kgrid.gridSize)*rho0;
    % medium.density(1:52,:)    = rho0/1.1;


% =========================================================================
%% Defining the source

% For the AcousticSource an initial pressure distribution is defined.
% Strictly this is an initial condition, but it models an impulsive
% acoustic source, eg. generated a laser pulse. This is defined on the grid.   
% In this case we will set it to take the form of a bell curve.

    source = AcousticSource(kgrid);
    source.initialPressure = exp( -(kgrid.x.^2 + kgrid.y.^2 + kgrid.z.^2) / (10*kgrid.dx^2) );

% Additionally, the initial acoustic fluid velocity can be defined as a
% gridField Vector, that is a 4D array of size (kgrid.Nx, kgrid.Ny,
% Kgrid.Nz, kgrid.dimensions). Nz (and Ny) defaults to 1 when the problem
% is 2D (or 1D). By default the initial velocity is 0 at time 0. 

    % source.initialVelocity = zeros([kgrid.gridSize,kgrid.dimensions]);
    % source.initialVelocity(:,:,:,1) = (1./(c0.*rho0)).*exp( -(kgrid.x.^2)/ (10*kgrid.dx^2));   % The x-component of the initial velocity 

% Note that while the initial velocity source is defined as the velocity
% distribution at the time 0, as for the initialPressure, the pressure and
% velocity outputs from AcousticSolver are shifted in time. This is
% described later. 

% =========================================================================
%% Running the solver

% In order to use acousticSolver, an acousticSolver instance must be
% initialised and the solver.run method used to run the solver. The inputs
% are, as stated: grid, medium, and source. A sensor may additonally be
% defined, as described below.

solver = AcousticSolver(kgrid,medium,source,[]);

% To run the solver we need to only call the run function, which takes
% inputs of the number of time steps and the timestep size. (The CFL and
% endtime may be given here too.) 

    dt1 = 1e-7;
    Nt1 = 200;

    solver.run(Nt=Nt1, dt=dt1);

% Calling this function again with the same or different values of Nt and
% dt will continue the simulation from the end time of the previous run
% call. For example, the following command will take the simulation to 250
% timesteps:

    solver.run(Nt=50,dt=dt1);

% The same result could have been achieved in one go using

    % solver = AcousticSolver(kgrid,medium,source,[]);
    % solver.run(Nt=250,dt=dt1);

% Calling the run function with Nt=0 will not run any additional time
% steps. If no time steps have been performed, it will just initialise the
% problem with the given values at time 0.

    % solver.run(Nt=0,dt=dt1);

% Following execution of run, the solver object will contain the following
% output properties:
% * solver.pressure         % A grid-sized array
% * solver.densitySplit     % A 4D gridfield vector
% * solver.velocity         % A 4D gridfield vector
% * solver.timeArray        % A vector of length (Nt+1)

% These are, respectively: 
% * The acoustic pressure field on the grid points at the end time Nt*dt.
% * The acoustic density field on the grid points at the final time, split
%   into directional co-ordinates (for the sake of the PML). The true
%   density field can be found by summing across the 4th dimension.
% * The acoustic fluid velocity in each of the co-ordinate directions,
%   evaluated on the staggered grid at time (Nt+0.5)*dt. (This is due to
%   the use of both space and time staggering.)
% * The time points used in the simulation including time 0.

% =========================================================================
%% Including acoustic absorption

% To include abosrption requires three additional steps:
% * defining the absorption coefficient,
% * defining the absorption power-law exponent,
% * turning on the absorption.
% The absorption coefficient is defined as a scalar on the grid, either as a
% constant value, or as a grid sized variable.

    alpha0 = 0.5;
    medium.absorptionCoeff = alpha0; % [dB/cm]

    % medium.absorptionCoeff = ones(kgrid.gridSize)*alpha0; % [dB/cm]

% The exponent of the frequency power law that the absorption follows must
% be a scalar value.

    medium.absorptionPower = 1.9;

% Now initialise the solver

    solver = AcousticSolver(kgrid,medium,source,[]);

% but before running the simulation, the solver must be told to take
% absorption into account by setting

    solver.absorptionType='on';

    % solver.absorptionType="noAbsorption";

    % solver.absorptionType="noDispersion";

% The options "noAbsorption" and "noDispersion" will use a reduced
% form of the equations, leaving out unnecessary terms. The default is  

    % solver.absorptionType = "off"

% The simulation is then run as before:

    solver.run(Nt=Nt1,dt=dt1);

 % =======================================================================
 %% Including a sensor
 %
 % AcousticSolver does not require a sensor to be defined, but if it is it
 % must have two properties, with an optional third. The sensor object is
 % initialised with the grid (the same grid used in the solver):
    
    sensor = AcousticSensor(kgrid);

 % An array of sensors can be defined as a binary mask. The solver will
 % return the field variables at the grid locations marked by 1 in the mask.

    sensor.mask = zeros(kgrid.gridSize);
    sensor.mask(floor(Nx/2)) = 1;

    % sensor.mask(floor(Nx/2)-5:floor(Nx/2)+5) = 1;

  % or in 2D/3D
    
    % sensor.mask(floor(Nx/2),floor(Ny/2)) = 1;

    % sensor.mask(floor(Nx/2),floor(Ny/2):Ny-10) = 1;

    % sensor.mask(floor(Nx/2),floor(Ny/2),15) = 1;

    % sensor.mask(floor(Nx/2),floor(Ny/2):Ny-10,floor(Nz/3)) = 1;

% The sensor type indicated which field variables to store. The default is
% just the acoustic pressure. For both the pressure and the density there
% are two options "on" and "off": 

    sensor.pressureSensor = 'on';
    sensor.densitySensor  = 'on';

    % sensor.pressureSensor = 'off';

    % sensor.densitySensor = 'off';

% while for the velocity there are three "on", "off" and "ongrid".
    
    sensor.velocitySensor = 'on';
    
    % sensor.velocitySensor = 'off';

    % sensor.velocitySensor = 'ongrid';

% The ongrid option returns the velocity on the grid (as opposed to the
% staggered grid that is the default for the velocity). Note that the time
% steps are staggered and these are not shifted: the velocity is returned
% at staggered time points.

% The final option is to define which timesteps the field is recorded at.
% The default is every time step, but setting

    sensor.timeSteps = 2;

% will record every second time step. Setting sensor.timeSteps = 3 would
% record every third timestep, etc. 

% Finally, the solver is initialised and run:

    solver = AcousticSolver(kgrid,medium,source,sensor);
    solver.run(Nt=10,dt=dt1);

% The outputs are stored in the solver as:
% * solver.sensor.pressure 
% * solver.sensor.densitySplit
% * solver.sensor.velocity
% * solver.sensor.times;
%
% The field variables are returned as matriced of size (number of 1s in the
% sensor mask) x (total number of time steps recorded). solver.sensor.times
% are the time points are the time points at which the data was recorded.