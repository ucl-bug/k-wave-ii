%% TestkWaveThermalSolver
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.TestGrid
%
% Unit tests for the kWaveThermalSolver class.
%
%% Description
% Runs the following tests for the kWaveThermalSolver:
% * Verifies simulations in homogeneous media match exact solution
% * Verifies that simulations using input parameters with a different grid
%   throw errors.

classdef TestkWaveThermalSolver < kwave.tests.unit.TestGrid

    % Parameterized tests.
    methods(Test, ParameterCombination="sequential")

        % Compare 1D, 2D, 3D initial value problem in homogeneous media
        % against exact solution.
        function initialValueProblemHomog(testCase)

            import matlab.unittest.constraints.IsEqualTo
            import kwave.toolbox.*
            
            % Medium.
            medium = kWaveThermalMedium(testCase.kgrid);
            medium.thermalConductivity = 0.52;
            medium.specificHeat = 3540;
            medium.density = 1000;
            
            % Source.
            source = kWaveThermalSource(testCase.kgrid);
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
            settings = kWaveSettings;
            settings.plotSimulation = 'off';
            
            % Solve using two steps.
            solver = kWaveThermalSolver(testCase.kgrid, medium, source, [], settings);
            Nt = 500;
            dt = 1;
            solver.takeTimeStep(Nt/2, dt);
            solver.takeTimeStep(Nt/2, dt);
            testCase.actualSolution = solver.temperature;

            % Compute exact Green's function solution.
            D = medium.thermalConductivity / (medium.density * medium.specificHeat);
            testCase.referenceSolution = kwave.legacy.bioheatExact(source.initialTemperature, 0, [D, 0, 0], testCase.kgrid.dx, (Nt - 1) * dt);

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

            kgridIncorrect = kWaveGrid(10, 2e-3);

            % Medium using correct kgrid.
            medium = kWaveThermalMedium(testCase.kgrid);
            medium.thermalConductivity = 0.52;
            medium.specificHeat = 3540;
            medium.density = 1000;

            % Medium using incorrect kgrid.
            mediumIncorrect = kWaveThermalMedium(kgridIncorrect);
            mediumIncorrect.thermalConductivity = 0.52;
            mediumIncorrect.specificHeat = 3540;
            mediumIncorrect.density = 1000;

            % Source using correct kgrid.
            source = kWaveThermalSource(testCase.kgrid);

            % Source using incorrect kgrid.
            sourceIncorrect = kWaveThermalSource(kgridIncorrect);

            testCase.verifyError(@() ...
                kWaveThermalSolver(testCase.kgrid, mediumIncorrect, source, []), ...
                'kWaveSolver:gridMismatch');

            testCase.verifyError(@() ...
                kWaveThermalSolver(testCase.kgrid, medium, sourceIncorrect, []), ...
                'kWaveSolver:gridMismatch');

        end

    end

end
