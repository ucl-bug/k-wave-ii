%% ThermalSolver
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.TimeDomainSolver
%
% Thermal solver.
%
%% Description
% |ThermalSolver| implements a time-domain solution to the diffusion
% equation in the form:
%
% $$\rho_0 C_p \frac{\partial T}{\partial t} = \nabla \cdot (K \nabla T)$$
%
% where $\rho_0$ is the density, $C_p$ is the specific heat capacity at
% constant pressure, $K$ is the thermal conductivity, $T$ is the
% temperature, and $t$ is time.
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
% After an object of the |ThermalSolver| class is created, the
% simulation is run by calling |solver.takeTimeStep(Nt, dt)|, where solver
% is the object name, |Nt| is the number of time steps to take, and |dt| is
% the size of the time step. During the simulation, a visualisation of the
% temperature field is displayed. The current temperature can be queried
% (or modified) at any point using the property |solver.temperature|.
%
%% Examples
% A simple of example of solving a initial value problem in 1D is shown
% below.
%
%   clearvars;
%   import kwave.toolbox.*
%     
%   % Grid.
%   kgrid = Grid(128, 1e-3);
%     
%   % Medium.
%   medium = ThermalMedium(kgrid);
%   medium.thermalConductivity = 0.52;
%   medium.specificHeat = 3540;
%   medium.density = 1000;
%     
%   % Source.
%   source = ThermalSource(kgrid);
%   source.initialTemperature = exp( -kgrid.xVec.^2 ./ (10 * kgrid.dx).^2 );
%     
%   % Solve.
%   solver = ThermalSolver(kgrid, medium, source, []);
%   solver.takeTimeStep(500, 0.5);
%     
%   % Plot.
%   figure;
%   plot(1e3 * kgrid.xVec, source.initialTemperature);
%   hold on;
%   plot(1e3 * kgrid.xVec, solver.temperature);
%   set(gca, 'YLim', [0, 1]);
%   grid on;
%   legend('T_0', 'T_{final}');
%   xlabel('Position [mm]');
%   ylabel('Temperature [degC]');
%
%% Input Arguments
% * |kgrid| - (kwave.toolbox.Grid) Object which defines the simulation grid
%   size.
% * |medium| - (kwave.toolbox.ThermalMedium) Object which defines the
%   medium properties.
% * |source| - (kwave.toolbox.ThermalSource) Object which defines the
%   source properties.
% * |sensor| - ...Not yet implemented...
% * |settings| - (kwave.toolbox.Settings) Object which defines the
%   simulation settings.
%
%% Properties
% * |temperature| - (numeric) Temperature field [degC].
%
%% Methods
% * |takeTimeStep|

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

classdef ThermalSolver < kwave.toolbox.TimeDomainSolver

    % PDE variables.
    properties(SetAccess=private, Dependent=true)
        temperature {mustBeReal, mustBeFinite}
    end

    % PDE variables on padded domain.
    properties(SetAccess=private, Hidden=true)
        temperaturePadded {mustBeReal, mustBeFinite}
    end

    % Constructor.
    methods
        function obj = ThermalSolver(kgrid, medium, source, sensor, settings)
            arguments
                kgrid(1,1) kwave.toolbox.Grid
                medium(1,1) kwave.toolbox.ThermalMedium
                source(1,1) kwave.toolbox.ThermalSource
                sensor
                settings(1,1) kwave.toolbox.Settings = kwave.toolbox.Settings
            end

            % Pass input arguments to superclass constructor.
            obj@kwave.toolbox.TimeDomainSolver(kgrid, medium, source, sensor, settings)

        end
    end

    % Get methods for PDE variables on non-padded grid.
    methods
        function temperature = get.temperature(obj)
            temperature = obj.kgrid.returnWithoutGridPadding(obj.temperaturePadded);
        end
    end

    % Override inherited setInitialConditions method.
    methods(Access=protected)
        setInitialConditions(obj)
    end

    % Concrete implementation of takeTimeStep method.
    methods
        takeTimeStep(obj, Nt, dt)
    end

end
