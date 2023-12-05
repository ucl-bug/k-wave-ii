%% TestThermalSolver
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.AbstractTestGrid
%
% Unit tests for the ThermalSolver class.
%
%% Description
% Runs the following tests for the ThermalSolver:
% * Verifies simulations in homogeneous media match exact solution
% * Verifies that simulations using input parameters with a different grid
%   throw errors.

classdef TestThermalSolver < kwave.tests.unit.AbstractTestGrid

    % Parameterized tests.
    methods(Test, ParameterCombination="sequential")

        % Compare 1D, 2D, 3D initial value problem in homogeneous media
        % against exact solution.
        function initialValueProblemHomog(testCase)

            import matlab.unittest.constraints.IsEqualTo
            import kwave.toolbox.*
            
            % Medium.
            medium = ThermalMedium(testCase.kgrid);
            medium.thermalConductivity = 0.52;
            medium.specificHeat = 3540;
            medium.density = 1000;
            
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
            Nt = 500;
            dt = 1;
            solver.takeTimeStep(Nt/2, dt);
            solver.takeTimeStep(Nt/2, dt);
            testCase.actualSolution = solver.temperaturePadded;

            % Compute exact Green's function solution.
            D = medium.thermalConductivityPadded / (medium.densityPadded * medium.specificHeatPadded);
            testCase.referenceSolution = kwave.legacy.bioheatExact(source.initialTemperaturePadded, 0, [D, 0, 0], testCase.kgrid.dx, (Nt - 1) * dt);

            % Compare with tolerance.
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

            % Turn on plotting and take a step.
            solver.settings.plotSimulation = 'on';
            solver.takeTimeStep(1, dt);

        end

        % Define medium and source inputs on a different grid, and test for
        % input errors.
        function testInputErrors(testCase)

            import kwave.toolbox.*

            kgridIncorrect = Grid(10, 2e-3);

            % Medium using correct kgrid.
            medium = ThermalMedium(testCase.kgrid);
            medium.thermalConductivity = 0.52;
            medium.specificHeat = 3540;
            medium.density = 1000;

            % Medium using incorrect kgrid.
            mediumIncorrect = ThermalMedium(kgridIncorrect);
            mediumIncorrect.thermalConductivity = 0.52;
            mediumIncorrect.specificHeat = 3540;
            mediumIncorrect.density = 1000;

            % Source using correct kgrid.
            source = ThermalSource(testCase.kgrid);

            % Source using incorrect kgrid.
            sourceIncorrect = ThermalSource(kgridIncorrect);

            testCase.verifyWarningFree(@() ...
                ThermalSolver(testCase.kgrid, medium, source, []));

            testCase.verifyError(@() ...
                ThermalSolver(testCase.kgrid, mediumIncorrect, source, []), ...
                'TimeDomainSolver:gridMismatch');

            testCase.verifyError(@() ...
                ThermalSolver(testCase.kgrid, medium, sourceIncorrect, []), ...
                'TimeDomainSolver:gridMismatch');

        end

    end

end
