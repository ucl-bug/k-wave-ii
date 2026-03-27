%% TestThermalSolverGrid
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.AbstractTestGrid
%
% Parameterised unit tests for the ThermalSolver class using grid sizes
% defined in |AbstractTestGrid|.
%
%% Description
% Runs the following tests for the ThermalSolver:
%
% * Verifies simulations in homogeneous media match exact solution

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

classdef TestThermalSolverGrid < kwave.tests.unit.AbstractTestGrid

    % Parameterized tests.
    methods(Test, ParameterCombination="sequential")

        % Compare 1D, 2D, 3D initial value problem in homogeneous media
        % against exact solution, with both medium types.
        function initialValueProblemHomog(testCase)

            import matlab.unittest.constraints.IsEqualTo
            import kwave.toolbox.*
            
            % Medium.
            medium = ThermalMedium(testCase.kgrid);
            medium.thermalConductivity = 0.52;
            medium.specificHeat = 3540;
            medium.density = 1000;

            medium2 = Medium(testCase.kgrid);
            medium2.materialIDGrid=1;
            
            % Source.
            source = ThermalSource(testCase.kgrid);
            variance = (3 * testCase.kgrid.dx)^2;
            gaussian = @(x) exp(-x.^2 / (2 * variance));
            switch testCase.kgrid.dimensions
                case 1
                    source.initialTemperature = ...
                        gaussian(testCase.kgrid.xVec);
                case 2
                    source.initialTemperature = ...
                        gaussian(testCase.kgrid.xVec) .* ...
                        gaussian(testCase.kgrid.yVec)';
                case 3
                    source.initialTemperature = ...
                        gaussian(testCase.kgrid.xVec) .* ...
                        gaussian(testCase.kgrid.yVec)' .* ...
                        reshape(gaussian(testCase.kgrid.zVec), 1, 1, []);
            end

            % Settings.
            settings = Settings;
            settings.plotSimulation = 'off';
            
            % Solve using two steps.
            solver = ThermalSolver(testCase.kgrid, medium, source, [], settings);
            solver1 = ThermalSolver(testCase.kgrid, medium2, source, [], settings);
            Nt = 500;
            dt = 1;
            solver.run(Nt=Nt/2, dt=dt);
            solver.run(Nt=Nt/2, dt=dt);
            solver1.run(Nt=Nt, dt=dt);

            testCase.actualSolution = solver.temperaturePadded;

            % Compute exact Green's function solution.
            D = medium.thermalConductivityPadded / (medium.densityPadded * medium.specificHeatPadded);
            testCase.referenceSolution = kwave.legacy.bioheatExact(source.initialTemperaturePadded, 0, [D, 0, 0], testCase.kgrid.dx, (Nt) * dt);

            % Compare with tolerance.
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));
            
            testCase.actualSolution = solver1.temperaturePadded; 
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

            % Take a step using auto-calculated Nt and dt.
            solver.run(EndTime=1);
            solver.run(CFL=0.5);
            solver.run;

            % Turn on plotting and take a step.
            solver.settings.plotSimulation = 'on';
            solver.run(Nt=1, dt=dt);

        end

    end

end
