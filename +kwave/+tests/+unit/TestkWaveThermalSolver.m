%% TestkWaveThermalSolver
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.TestGrid
%
% Unit tests for the kWaveThermalSolver class.

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
            
            % Solve.
            solver = kWaveThermalSolver(testCase.kgrid, medium, source, [], settings);
            Nt = 500;
            dt = 1;
            solver.takeTimeStep(Nt, dt);
            testCase.actualSolution = solver.temperature;

            % Compute exact Green's function solution.
            D = medium.thermalConductivity / (medium.density * medium.specificHeat);
            testCase.referenceSolution = kwave.legacy.bioheatExact(source.initialTemperature, 0, [D, 0, 0], testCase.kgrid.dx, (Nt - 1) * dt);

            % Compare with tolerance.
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

        end

    end

end
