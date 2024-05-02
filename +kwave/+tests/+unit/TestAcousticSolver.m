%% TestAcousticSolver
% *Package:* kwave.tests.unit
% *Superclasses:* matlab.unittest.TestCase
%
% Non-parameterised unit tests for the AcousticSolver class. Use this test
% class for tests that do not require automatically sweeping over the grid
% sizes defined in |AbstractTestGrid|.
%
%% Description
% Runs the following tests for the AcousticSolver:
% * Verifies that plane wave simulations in 2D and 3D match simulations in
%   1D.

classdef TestAcousticSolver < matlab.unittest.TestCase

    methods(Test)

        % Compare plane waves in 2D and 3D against a reference simulation
        % in 1D.
        function testPlaneWaves(testCase)

            import kwave.toolbox.*
            import matlab.unittest.constraints.IsEqualTo

            % Define tolerance for field comparisons.
            tol = matlab.unittest.constraints.AbsoluteTolerance(single(1e-6));

            % Test properties.
            Nax = 128;
            Nlat = 8;
            dx = 1e-3;
            c0 = 1500;
            rho0 = 1000;
            pmlSize = 20;
            CFL = 0.5;
            Nt = 100;
            dt = CFL * dx / c0;

            % Settings.
            settings = Settings;
            settings.plotSimulation = 'off';

            % 1D simulation (reference)
            kgrid1D = Grid(Nax, dx, pmlSize);
            medium1D = AcousticMedium(kgrid1D);
            medium1D.soundSpeed = c0;
            medium1D.density = rho0;
            source1D = AcousticSource(kgrid1D);
            source1D.initialPressure = exp( -(kgrid1D.xVec - 25e-3).^2 ./ (5 * kgrid1D.dx).^2 );
            solver1D = AcousticSolver(kgrid1D, medium1D, source1D, [], settings);
            solver1D.run(Nt=Nt, dt=dt);
            pressure1D = solver1D.pressure;
            density1D = solver1D.densitySplit;
            velocity1D = solver1D.velocity;

            % 2D-x simulation
            kgrid2Dx = Grid([Nax, Nlat], dx, [pmlSize, 0]);
            medium2Dx = AcousticMedium(kgrid2Dx);
            medium2Dx.soundSpeed = c0;
            medium2Dx.density = rho0;
            source2Dx = AcousticSource(kgrid2Dx);
            source2Dx.initialPressure = repmat(source1D.initialPressure, [1, Nlat]);
            solver2Dx = AcousticSolver(kgrid2Dx, medium2Dx, source2Dx, [], settings);
            solver2Dx.run(Nt=Nt, dt=dt);
            pressure2Dx = squeeze(solver2Dx.pressure(:, end/2));
            density2Dx = squeeze(solver2Dx.densitySplit(:, end/2, 1, 1));
            velocity2Dx = squeeze(solver2Dx.velocity(:, end/2, 1, 1));

            testCase.verifyThat(pressure2Dx, IsEqualTo(pressure1D, "Within", tol));
            testCase.verifyThat(density2Dx,  IsEqualTo(density1D,  "Within", tol));
            testCase.verifyThat(velocity2Dx, IsEqualTo(velocity1D, "Within", tol));

            % 2D-y simulation
            kgrid2Dy = Grid([Nlat, Nax], dx, [0, pmlSize]);
            medium2Dy = AcousticMedium(kgrid2Dy);
            medium2Dy.soundSpeed = c0;
            medium2Dy.density = rho0;
            source2Dy = AcousticSource(kgrid2Dy);
            source2Dy.initialPressure = repmat(reshape(source1D.initialPressure, 1, []), [Nlat, 1]);
            solver2Dy = AcousticSolver(kgrid2Dy, medium2Dy, source2Dy, [], settings);
            solver2Dy.run(Nt=Nt, dt=dt);
            pressure2Dy = reshape(squeeze(solver2Dy.pressure(end/2, :)), [], 1);
            density2Dy = reshape(squeeze(solver2Dy.densitySplit(end/2, :, 1, 2)), [], 1);
            velocity2Dy = reshape(squeeze(solver2Dy.velocity(end/2, :, 1, 2)), [], 1);

            testCase.verifyThat(pressure2Dy, IsEqualTo(pressure1D, "Within", tol));
            testCase.verifyThat(density2Dy,  IsEqualTo(density1D,  "Within", tol));
            testCase.verifyThat(velocity2Dy, IsEqualTo(velocity1D, "Within", tol));

            % 3D-x simulation
            kgrid3Dx = Grid([Nax, Nlat, Nlat], dx, [pmlSize, 0, 0]);
            medium3Dx = AcousticMedium(kgrid3Dx);
            medium3Dx.soundSpeed = c0;
            medium3Dx.density = rho0;
            source3Dx = AcousticSource(kgrid3Dx);
            source3Dx.initialPressure = repmat(source1D.initialPressure, [1, Nlat, Nlat]);
            solver3Dx = AcousticSolver(kgrid3Dx, medium3Dx, source3Dx, [], settings);
            solver3Dx.run(Nt=Nt, dt=dt);
            pressure3Dx = squeeze(solver3Dx.pressure(:, end/2, end/2));
            density3Dx = squeeze(solver3Dx.densitySplit(:, end/2, end/2, 1));
            velocity3Dx = squeeze(solver3Dx.velocity(:, end/2, end/2, 1));

            testCase.verifyThat(pressure3Dx, IsEqualTo(pressure1D, "Within", tol));
            testCase.verifyThat(density3Dx,  IsEqualTo(density1D,  "Within", tol));
            testCase.verifyThat(velocity3Dx, IsEqualTo(velocity1D, "Within", tol));

            % 3D-y simulation
            kgrid3Dy = Grid([Nlat, Nax, Nlat], dx, [0, pmlSize, 0]);
            medium3Dy = AcousticMedium(kgrid3Dy);
            medium3Dy.soundSpeed = c0;
            medium3Dy.density = rho0;
            source3Dy = AcousticSource(kgrid3Dy);
            source3Dy.initialPressure = repmat(reshape(source1D.initialPressure, 1, [], 1), [Nlat, 1, Nlat]);
            solver3Dy = AcousticSolver(kgrid3Dy, medium3Dy, source3Dy, [], settings);
            solver3Dy.run(Nt=Nt, dt=dt);
            pressure3Dy = reshape(squeeze(solver3Dy.pressure(end/2, :, end/2)), [], 1, 1);
            density3Dy = reshape(squeeze(solver3Dy.densitySplit(end/2, :, end/2, 2)), [], 1, 1);
            velocity3Dy = reshape(squeeze(solver3Dy.velocity(end/2, :, end/2, 2)), [], 1, 1);

            testCase.verifyThat(pressure3Dy, IsEqualTo(pressure1D, "Within", tol));
            testCase.verifyThat(density3Dy,  IsEqualTo(density1D,  "Within", tol));
            testCase.verifyThat(velocity3Dy, IsEqualTo(velocity1D, "Within", tol));

            % 3D-z simulation
            kgrid3Dz = Grid([Nlat, Nlat, Nax], dx, [0, 0, pmlSize]);
            medium3Dz = AcousticMedium(kgrid3Dz);
            medium3Dz.soundSpeed = c0;
            medium3Dz.density = rho0;
            source3Dz = AcousticSource(kgrid3Dz);
            source3Dz.initialPressure = repmat(reshape(source1D.initialPressure, 1, 1, []), [Nlat, Nlat, 1]);
            solver3Dz = AcousticSolver(kgrid3Dz, medium3Dz, source3Dz, [], settings);
            solver3Dz.run(Nt=Nt, dt=dt);
            pressure3Dz = reshape(squeeze(solver3Dz.pressure(end/2, end/2, :)), [], 1, 1);
            density3Dz = reshape(squeeze(solver3Dz.densitySplit(end/2, end/2, :, 3)), [], 1, 1);
            velocity3Dz = reshape(squeeze(solver3Dz.velocity(end/2, end/2, :, 3)), [], 1, 1);

            testCase.verifyThat(pressure3Dz, IsEqualTo(pressure1D, "Within", tol));
            testCase.verifyThat(density3Dz,  IsEqualTo(density1D,  "Within", tol));
            testCase.verifyThat(velocity3Dz, IsEqualTo(velocity1D, "Within", tol));

        end

    end

end
