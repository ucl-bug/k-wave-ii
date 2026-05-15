%% TestAcousticSolverGrid
% *Package:* kwave.tests.unit
% *Superclasses:* matlab.unittest.AbstractTestGrid
%
% Parameterised unit tests for the AcousticSolver class using grid sizes
% defined in |AbstractTestGrid|.
%
%% Description
% Runs the following tests for the AcousticSolver:
%
% * Verifies that initial value problems in a homogeneous and lossless
%   medium match k-Wave-I.
% * Verifies that if the initial velocity is specified as 0 the result is
% the same as if it was not specified.

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
            kgridRef.setTime(Nt+1, dt);
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

        function testInitialVelocitySteps(testCase)

            import kwave.toolbox.*
            import matlab.unittest.constraints.IsEqualTo

            medium = AcousticMedium(testCase.kgrid);
            c0 = 1500;
            medium.soundSpeed = c0;
            medium.density = 1000;
            source = AcousticSource(testCase.kgrid);
            source2 = AcousticSource(testCase.kgrid);
            source.initialPressure = exp( -testCase.kgrid.dimensions*(testCase.kgrid.x.^2+testCase.kgrid.y.^2+testCase.kgrid.z.^2) ./ (5 * testCase.kgrid.dx).^2 );
            source2.initialPressure = exp( -testCase.kgrid.dimensions*(testCase.kgrid.x.^2+testCase.kgrid.y.^2+testCase.kgrid.z.^2) ./ (5 * testCase.kgrid.dx).^2 );
            source2.initialVelocity = 0;
            settings = Settings;
            settings.plotSimulation = 'off';

            % Solve.
            solver = AcousticSolver(testCase.kgrid, medium, source, [], settings);
            solver1 = AcousticSolver(testCase.kgrid, medium, source, [], settings);
            solver2 = AcousticSolver(testCase.kgrid, medium, source2, [], settings);
            dt = 0.25 * testCase.kgrid.dx / c0;
            solver.run(Nt=0, dt=dt);
            solver2.run(Nt=0, dt=dt);
            solver.pressure;
            testCase.verifyThat(solver.pressure, IsEqualTo(solver2.pressure, "Within", testCase.tol));
            solver.run(Nt=3, dt=dt);
            solver2.run(Nt=3, dt=dt);
            testCase.verifyThat(solver.pressure, IsEqualTo(solver2.pressure, "Within", testCase.tol));
            testCase.verifyThat(solver.velocity, IsEqualTo(solver2.velocity, "Within", testCase.tol));
            solver.run(Nt=22, dt=dt);
            solver2.run(Nt=22, dt=dt);
            testCase.verifyThat(solver.pressure, IsEqualTo(solver2.pressure, "Within", testCase.tol));
            testCase.verifyThat(solver.velocity, IsEqualTo(solver2.velocity, "Within", testCase.tol));
            solver1.run(Nt=25, dt=dt);
            testCase.verifyThat(solver.pressure, IsEqualTo(solver1.pressure, "Within", testCase.tol));
            testCase.verifyThat(solver.velocity, IsEqualTo(solver1.velocity, "Within", testCase.tol));
            testCase.verifyThat(solver2.pressure, IsEqualTo(solver1.pressure, "Within", testCase.tol));
            testCase.verifyThat(solver2.velocity, IsEqualTo(solver1.velocity, "Within", testCase.tol));
            
            medium.absorptionPower=1.9;
            medium.absorptionCoeff=0.5;
            solver2 = AcousticSolver(testCase.kgrid, medium, source2, [], settings);
            solver2.absorptionType='on';
            solver2.run(Nt=3, dt=dt);
        end

    end

end
