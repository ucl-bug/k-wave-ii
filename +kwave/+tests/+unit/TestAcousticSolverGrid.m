%% TestAcousticSolverGrid
% *Package:* kwave.tests.unit
% *Superclasses:* matlab.unittest.AbstractTestGrid
%
% Parameterised unit tests for the AcousticSolver class using grid sizes
% defined in |AbstractTestGrid|.
%
%% Description
% Runs the following tests for the AcousticSolver:
% * Verifies that initial value problems in a homogeneous and lossless
%   medium match k-Wave-I.

classdef TestAcousticSolverGrid < kwave.tests.unit.AbstractTestGrid

    % Parameterized tests.
    methods(Test, ParameterCombination="sequential")

        % Compare 1D, 2D, 3D initial value problems in homogeneous and
        % lossless media against k-Wave-I.
        function initialValueProblemHomog(testCase)

            import kwave.toolbox.*
            import matlab.unittest.constraints.IsEqualTo
 
            % Medium.
            medium = AcousticMedium(testCase.kgrid);
            c0 = 1500;
            medium.soundSpeed = c0;
            medium.density = 1000;
            
            % Source.
            source = AcousticSource(testCase.kgrid);
            variance = (1 * testCase.kgrid.dx)^2;
            gaussian = @(x) exp(-x.^2 / (2 * variance));
            switch testCase.kgrid.dimensions
                case 1
                    source.initialPressure = ...
                        gaussian(testCase.kgrid.xVec);
                case 2
                    source.initialPressure = ...
                        gaussian(testCase.kgrid.xVec) .* ...
                        gaussian(testCase.kgrid.yVec)';
                case 3
                    source.initialPressure = ...
                        gaussian(testCase.kgrid.xVec) .* ...
                        gaussian(testCase.kgrid.yVec)' .* ...
                        reshape(gaussian(testCase.kgrid.zVec), 1, 1, []);
            end

            % Settings.
            settings = Settings;
            settings.plotSimulation = 'off';
            
            % Solve.
            solver = AcousticSolver(testCase.kgrid, medium, source, [], settings);
            Nt = 25;
            dt = 0.25 * testCase.kgrid.dx / c0;
            solver.run(Nt=Nt, dt=dt);
            testCase.actualSolution = solver.pressure;

            % Compute reference solution using k-Wave-I.
            switch testCase.kgrid.dimensions
                case 1
                    functionRef = @kwave.legacy.kspaceFirstOrder1D;
                    kgridRef = kwave.legacy.kWaveGrid(...
                        testCase.kgrid.Nx, testCase.kgrid.dx);
                case 2
                    functionRef = @kwave.legacy.kspaceFirstOrder2D;
                    kgridRef = kwave.legacy.kWaveGrid(...
                        testCase.kgrid.Nx, testCase.kgrid.dx, ...
                        testCase.kgrid.Ny, testCase.kgrid.dy);
                case 3
                    functionRef = @kwave.legacy.kspaceFirstOrder3D;
                    kgridRef = kwave.legacy.kWaveGrid(...
                        testCase.kgrid.Nx, testCase.kgrid.dx, ...
                        testCase.kgrid.Ny, testCase.kgrid.dy, ...
                        testCase.kgrid.Nz, testCase.kgrid.dz);
            end
            kgridRef.setTime(Nt, dt);
            mediumRef.sound_speed = medium.soundSpeed;
            mediumRef.sound_speed_ref = medium.soundSpeedReference;
            mediumRef.density = medium.density;
            sourceRef.p0 = source.initialPressure;
            sensorRef.record = {'p_final'};
            sensorDataRef = functionRef(kgridRef, mediumRef, sourceRef, sensorRef, ...
                'PlotSim', false, ...
                'Smooth', false, ...
                'PMLInside', false, ...
                'PMLSize', testCase.kgrid.gridPadding(1:testCase.kgrid.dimensions), ...
                'DataCast', 'single');
            testCase.referenceSolution = sensorDataRef.p_final;

            % Compare with tolerance.
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

            % Take a step using auto-calculated Nt and dt.
            solver.run(EndTime=0.5e-6);
            solver.run(CFL=0.5);
            solver.run;

            % Turn on plotting and take a step.
            solver.settings.plotSimulation = 'on';
            solver.run(Nt=1, dt=dt);

        end

    end

end
