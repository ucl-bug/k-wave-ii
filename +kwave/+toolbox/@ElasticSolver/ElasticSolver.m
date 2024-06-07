%% ElasticSolver
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.TimeDomainSolver
%
% Time domain elastic wave solver.
%
%% Description
% |ElasticSolver| implements a time-domain solution to the elastic
% wave equation written as two coupled equations.  The lossess equation takes the form:
%
% $$\frac{\partial \sigma_{ij}}{\partial t} = \lambda \delta_{ij} \frac{\partial v_k}{x_k} + \mu\left(\frac{\partial v_i}{\partial x_j} + \frac{\partial v_j}{\partial x_i}\right) $$
%
% $$\frac{\partial v_i}{\partial t} = \frac{1}{\rho_0} \frac{\partial \sigma_{ij}}{\partial x_j}$$
%
% $$\frac{\partial \sigma}{\partial t} = \lambda \nabla \cdot \mathbf{v} \mathbf{I} + \mu (\nabla \mathbf{v} + \nabla \mathbf{v} ^ T)$$
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
% After an object of the |ElasticSolver| class is created, the simulation
% is run by calling |solver.run|. During the simulation, a visualisation of
% the pressure field is displayed. The current pressure can be queried (or
% modified) at any point using the property |solver.pressure|.
%
%% Examples
% A simple of example of solving a initial value problem in 1D is shown
% below.
%FourierCollocation
%   clearvars;
%   import kwave.toolbox.*
%   
%   % Grid.
%   kgrid = Grid(128, 1e-3, 20);
%   
%   % Medium.
%   medium = ElasticMedium(kgrid);
%   medium.density = 1000;
%   medium.soundSpeedCompression = 1500;
%   medium.soundSpeedShear = 800;
%   ...
%   
%   % Source.
%   source = ElasticSource(kgrid);
%   source.initialPressure = exp( -kgrid.xVec.^2 ./ (10 * kgrid.dx).^2 );
%   
%   % Settings.
%   settings = Settings;
%   settings.plotFrequency = 1;
%   
%   % Solve.
%   solver = ElasticSolver(kgrid, medium, source, [], settings);
%   CFL = 0.5;
%   dt = CFL .* kgrid.dx ./ max(medium.soundSpeedCompression, medium.soundSpeedShear);
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
% * |medium| - (kwave.toolbox.ElasticMedium) Object which defines the
%   medium properties.
% * |source| - (kwave.toolbox.ElasticSource) Object which defines the
%   source properties.
% * |sensor| - ...Not yet implemented...
% * |settings| - (kwave.toolbox.Settings) Object which defines the
%   simulation settings.
%
%% Properties
% * |pressure| - (numeric) Pressure field [Pa].
% * |velocity| - (numeric) Vector field of the elastic particle velocity
%   [m/s]

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

classdef ElasticSolver < kwave.toolbox.TimeDomainSolver

    % PDE variables.
    properties(SetAccess=private, Dependent=true)
        velocity
        stress
    end

    % PDE variables on padded domain, and PML variables.
    properties(SetAccess=private, Hidden=true)
        velocityPadded single
        stressPadded single
        pressure
        mu
        lambda
        pml kwave.toolbox.SplitFieldPML
    end

    % Constructor.
    methods
        function obj = ElasticSolver(kgrid, medium, source, sensor, settings)
            arguments
                kgrid(1,1) kwave.toolbox.Grid
                medium(1,1) kwave.toolbox.ElasticMedium
                source(1,1) kwave.toolbox.ElasticSource
                sensor
                settings(1,1) kwave.toolbox.Settings = kwave.toolbox.Settings
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
        function velocity = get.velocity(obj)
            velocity = obj.kgrid.returnWithoutGridPadding(obj.velocityPadded);
        end
        function stress = get.stress(obj)
            stress = obj.kgrid.returnWithoutGridPadding(obj.stressPadded);
        end

    end

    % Override inherited methods.
    methods(Access=protected)
        setInitialConditions(obj)
        executeTimeStep(obj, Nt, dt)
        [Nt, dt] = autoComputeTimeStep(obj, CFL, EndTime)
    end

end
