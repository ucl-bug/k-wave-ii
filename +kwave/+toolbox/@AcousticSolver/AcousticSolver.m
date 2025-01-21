%% AcousticSolver
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.TimeDomainSolver
%
% Time domain acoustic wave solver.
%
%% Description
% |AcousticSolver| implements a time-domain solution to the wave equation
% written as three coupled equations in the form:
%
% $$\frac{\partial \vec{u}}{\partial t} = -\frac{1}{\rho_0} \nabla (p)$$
%
% $$\frac{\partial \rho}{\partial t} = -\rho_0 \nabla \cdot (\vec{u})$$
%
% $$p = c_0^2 \rho$$
%
% When absorption y is declared as a medium property
%
% $$p= c_0^2 \rho + \tau (-\nabla^2)^(y/2 -1)\frac{\partial \rho}{\partial t} + \eta (-\nabla^2)^((y-1)/2)\rho$$
%
% where $p$ is the acoustic pressure, $\vec{u}$ is the acoustic particle
% velocity, $\rho$ is the acoustic density, $\rho_0$ is the ambient
% density, $c_0$ is the sound speed, and $t$ is time.
%
% The computation is based on a k-space pseudospectral scheme in which
% spatial gradients are calculated using the Fourier collocation spectral
% method, and temporal gradients are calculated using a k-space corrected
% finite difference scheme. For a homogeneous medium, the formulation is
% exact and unconditionally stable. For a heterogeneous medium, the time
% scheme allows larger time-steps to be taken for the same level of
% accuracy compared to conventional pseudospectral time-domain methods.
%
% The simulation is defined by five input objects which define the
% computational grid, medium properties, sources, sensors, and settings.
%
% After an object of the |AcousticSolver| class is created, the simulation
% is run by calling |solver.run|. During the simulation, a visualisation of
% the pressure field is displayed. The current pressure can be queried (or
% modified) at any point using the property |solver.pressure|.
%
%% Examples
% A simple of example of solving a initial value problem in 1D is shown
% below.
%
%   clearvars;
%   import kwave.toolbox.*
%   
%   % Grid.
%   kgrid = Grid(128, 1e-3, 20);
%   
%   % Medium.
%   medium = AcousticMedium(kgrid);
%   medium.soundSpeed = 1500;
%   medium.density = 1000;
%   
%   % Source.
%   source = AcousticSource(kgrid);
%   source.initialPressure = exp( -kgrid.xVec.^2 ./ (10 * kgrid.dx).^2 );
%   
%   % Settings.
%   settings = Settings;
%   settings.plotFrequency = 1;
%   
%   % Solve.
%   solver = AcousticSolver(kgrid, medium, source, [], settings);
%   CFL = 0.5;
%   dt = CFL * kgrid.dx / medium.soundSpeed;
%   solver.run(Nt=80, dt=dt);
%   
%   % Plot.
%   figure;
%   plot(1e3 * kgrid.xVec, source.initialPressure);
%   hold on;
%   plot(1e3 * kgrid.xVec, solver.pressure);
%   set(gca, 'YLim', [0, 1]);
%   grid on;
%   legend('p_0', 'p_{final}');
%   xlabel('Position [mm]');
%   ylabel('Pressure [Pa]');
%
%% Input Arguments
% * |kgrid| - (kwave.toolbox.Grid) Object which defines the simulation grid
%   size.
% * |medium| - (kwave.toolbox.AcousticMedium) Object which defines the
%   medium properties.
% * |source| - (kwave.toolbox.AcousticSource) Object which defines the
%   source properties.
% * |sensor| - ...Not yet implemented...
% * |settings| - (kwave.toolbox.Settings) Object which defines the
%   simulation settings.
%
%% Properties
% * |pressure| - (numeric) Pressure field [Pa].
% * |densitySplit| - (numeric) Vector field of the split-field components
%   of the acoustic density [kg/m^3].
% * |velocity| - (numeric) Vector field of the acoustic particle velocity
%   [m/s]
% * |absorptionType|- (string) Must be a member of { 'on', 'off',
% 'noAbsorption', 'noDispersion'} defaults to 'off'. Switch to include to
% exclude each of the absorption terms within the equation of state.
%
%% Methods
% * |setkSpaceCorrection|
% * |setAbsorptionCoefficients|
% * |kappaSplitCorrection|
%
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

classdef AcousticSolver < kwave.toolbox.TimeDomainSolver

    % PDE variables.
    properties(SetAccess=private, Dependent=true)
        pressure
        densitySplit
        velocity
    end

    % PDE variables on padded domain, and PML variables.
    properties(SetAccess=private, Hidden=true)
        pressurePadded single
        densitySplitPadded single
        velocityPadded single
        pml kwave.toolbox.SplitFieldPML
    end
    
    properties(SetAccess=public,Hidden=false)
        absorptionType char {mustBeMember( absorptionType, {'off','on', 'noAbsorption', 'noDispersion'})} = 'off'
    end

    properties(SetAccess=private, Hidden=true)
        absorbTauPadded single
        absorbEtaPadded single
        kappaSplit single

        BoundCond char {mustBeMember( BoundCond, {'off','on'})} = 'off'
        BoundaryCondition kwave.toolbox.BoundaryCondition
        timePoint = 0 ; 
    end

    % Constructor.
    methods
        function obj = AcousticSolver(kgrid, medium, source, sensor, settings)
            arguments
                kgrid(1,1) kwave.toolbox.Grid
                medium(1,1) kwave.toolbox.GridInput
                source(1,1) kwave.toolbox.AcousticSource
                sensor
                settings(1,1) kwave.toolbox.Settings = kwave.toolbox.Settings
            end

            % Need way to check is medium ir a Medium Class or an
            % AcousticMedium Class
            
                if ~(isa(medium, 'kwave.toolbox.Medium') || isa(medium, 'kwave.toolbox.AcousticMedium'))
                    error('AcousticSolver:InvalidMediumType',...
                        'medium must be an object of Medium OR AcousticMedium.');
                end

                if ~(isempty(sensor) || isa(sensor, 'kwave.toolbox.AcousticSensor'))
                    error('AcousticSolver:InvalidSensorType',...
                        'sensor must be an AcousticSensor or be left empty [].');
                end

            % Pass input arguments to superclass constructor. This calls
                % setInitialConditions.
                obj@kwave.toolbox.TimeDomainSolver(kgrid, medium, source, sensor, settings);
                % Initialise PML object.
                obj.pml = kwave.toolbox.SplitFieldPML(obj.kgrid);
        end
    end

    % Get methods for PDE variables on non-padded grid.
    methods
        function pressure = get.pressure(obj)
            pressure = obj.kgrid.returnWithoutGridPadding(obj.pressurePadded);
        end
        function densitySplit = get.densitySplit(obj)
            densitySplit = obj.kgrid.returnWithoutGridPadding(obj.densitySplitPadded);
        end
        function velocity = get.velocity(obj)
            velocity = obj.kgrid.returnWithoutGridPadding(obj.velocityPadded);
        end
    end
    
    % Override inherited methods and add specific methods.
    methods(Access=protected)
        setInitialConditions(obj)
        executeTimeStep(obj, Nt, dt)
        [Nt, dt] = autoComputeTimeStep(obj, CFL, EndTime)
        setAbsorptionCoefficients(obj)
        setkSpaceCorrection(obj, dt);
        fCorrected = kappaSplitCorrection(obj, f);
        
    end

    methods(Access=public)
        setBoundaryCondition(obj,BoundaryCondition);
    end
end
