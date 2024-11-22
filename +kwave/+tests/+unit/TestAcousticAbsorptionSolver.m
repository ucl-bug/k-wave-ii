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

classdef TestAcousticAbsorptionSolver < matlab.unittest.TestCase

    methods(Test)

        % Compare plane waves in 2D and 3D against a reference simulation
        % in 1D.
        function testPlaneWaves(testCase)

            import kwave.toolbox.*
            import matlab.unittest.constraints.IsEqualTo

            % Define tolerance for field comparisons.
            tol = matlab.unittest.constraints.AbsoluteTolerance(single(1e-6));

            % Test properties.
            Nax = 256;
            Nlat = 16;
            dx = 4e-3;
            c0 = 1500;
            rho0 = 1000;
            pmlSize = 20;
            CFL = 0.5;
            Nt = 150;
            dt = CFL * dx / c0;

            % Settings.
            settings = Settings;
            settings.plotSimulation = 'off';

            settingsp = Settings;
            settingsp.plotSimulation = 'on';

            for EquationType=1:2
                if EquationType==1
                    SolverType = @(kgrid, medium, source, sensor, setting) AcousticSolver(kgrid, medium, source, sensor, setting);
                    pow=1.9;
                    coe=10;
                    typ='none'; %All absorption is turned off
                    Cases=5;
                elseif EquationType==2
                    SolverType = @(kgrid, medium, source, sensor, setting) AcousticAbsorptionSolver(kgrid, medium, source, sensor, setting);
                    Cases=1;
                end
                while Cases<=5
                    if EquationType==2
                        if Cases==1
                            pow=1.9;
                            coe=10;
                            typ='none'; %All absorption is turned off
                        elseif Cases==2
                            pow=1.9;
                            coe=10;
                            typ='noDispersion'; % dispersion (eta) is turned off
                        elseif Cases==3
                            pow=1.9;
                            coe=10;
                            typ='noAbsorption'; % absorption (tau) is turned off
                        elseif Cases==4
                            pow=1.9;
                            coe=10;
                            typ='noType'; % all absorption is on
                        elseif Cases==5
                            pow=1.1;
                            typ='noType'; % all absorption is on
                        end
                    end
                    % 1D simulation (reference)
                    kgrid1D = Grid(Nax, dx, pmlSize);
                    if EquationType==2 && Cases==5
                        coe=10*ones(Nax,1);
                        coe(floor(Nax/3):floor(2*Nax/3))=15;
                    end
                    medium1D = AcousticMedium(kgrid1D);
                    medium1D.soundSpeed = c0;
                    medium1D.density = rho0;
                    medium1D.absorptionPower=pow;
                    medium1D.absorptionCoeff=coe;
                    medium1D.absorptionType=typ;
                    source1D = AcousticSource(kgrid1D);
                    source1D.initialPressure = exp( -(kgrid1D.xVec - 25e-3).^2 ./ (5 * kgrid1D.dx).^2 );
                    solver1D = SolverType(kgrid1D, medium1D, source1D, [], settingsp);
                    solver1D.run(Nt=Nt, dt=dt);
                    pressure1D = solver1D.pressure;
                    density1D = solver1D.densitySplit;
                    velocity1D = solver1D.velocity;

                    % 2D-x simulation
                    kgrid2Dx = Grid([Nax, Nlat], dx, [pmlSize, 0]);
                    medium2Dx = AcousticMedium(kgrid2Dx);
                    if EquationType==2 && Cases==5
                        coe=10*ones(Nax,Nlat);
                        coe(floor(Nax/3):floor(2*Nax/3),:)=15;
                    end
                    medium2Dx.soundSpeed = c0;
                    medium2Dx.density = rho0;
                    medium2Dx.absorptionPower=pow;
                    medium2Dx.absorptionCoeff=coe;
                    medium2Dx.absorptionType=typ;
                    source2Dx = AcousticSource(kgrid2Dx);
                    source2Dx.initialPressure = repmat(source1D.initialPressure, [1, Nlat]);
                    solver2Dx = SolverType(kgrid2Dx, medium2Dx, source2Dx, [], settings);
                    solver2Dx.run(Nt=Nt, dt=dt);
                    pressure2Dx = squeeze(solver2Dx.pressure(:, end/2));
                    density2Dx = squeeze(solver2Dx.densitySplit(:, end/2, 1, 1));
                    velocity2Dx = squeeze(solver2Dx.velocity(:, end/2, 1, 1));

                    testCase.verifyThat(pressure2Dx, IsEqualTo(pressure1D, "Within", tol));
                    testCase.verifyThat(density2Dx,  IsEqualTo(density1D,  "Within", tol));
                    testCase.verifyThat(velocity2Dx, IsEqualTo(velocity1D, "Within", tol));

                    % 2D-y simulation
                    kgrid2Dy = Grid([Nlat, Nax], dx, [0, pmlSize]);
                    if EquationType==2 && Cases==5
                        coe=10*ones(Nlat,Nax);
                        coe(:,floor(Nax/3):floor(2*Nax/3))=15;
                    end
                    medium2Dy = AcousticMedium(kgrid2Dy);
                    medium2Dy.soundSpeed = c0;
                    medium2Dy.density = rho0;
                    medium2Dy.absorptionPower=pow;
                    medium2Dy.absorptionCoeff=coe;
                    medium2Dy.absorptionType=typ;
                    source2Dy = AcousticSource(kgrid2Dy);
                    source2Dy.initialPressure = repmat(reshape(source1D.initialPressure, 1, []), [Nlat, 1]);
                    solver2Dy = SolverType(kgrid2Dy, medium2Dy, source2Dy, [], settings);
                    solver2Dy.run(Nt=Nt, dt=dt);
                    pressure2Dy = reshape(squeeze(solver2Dy.pressure(end/2, :)), [], 1);
                    density2Dy = reshape(squeeze(solver2Dy.densitySplit(end/2, :, 1, 2)), [], 1);
                    velocity2Dy = reshape(squeeze(solver2Dy.velocity(end/2, :, 1, 2)), [], 1);

                    testCase.verifyThat(pressure2Dy, IsEqualTo(pressure1D, "Within", tol));
                    testCase.verifyThat(density2Dy,  IsEqualTo(density1D,  "Within", tol));
                    testCase.verifyThat(velocity2Dy, IsEqualTo(velocity1D, "Within", tol));

                    % 3D-x simulation
                    kgrid3Dx = Grid([Nax, Nlat, Nlat], dx, [pmlSize, 0, 0]);
                    if EquationType==2 && Cases==5
                        coe=10*ones(Nax,Nlat,Nlat);
                        coe(floor(Nax/3):floor(2*Nax/3),:,:)=15;
                    end
                    medium3Dx = AcousticMedium(kgrid3Dx);
                    medium3Dx.soundSpeed = c0;
                    medium3Dx.density = rho0;
                    medium3Dx.absorptionPower=pow;
                    medium3Dx.absorptionCoeff=coe;
                    medium3Dx.absorptionType=typ;
                    source3Dx = AcousticSource(kgrid3Dx);
                    source3Dx.initialPressure = repmat(source1D.initialPressure, [1, Nlat, Nlat]);
                    solver3Dx = SolverType(kgrid3Dx, medium3Dx, source3Dx, [], settings);
                    solver3Dx.run(Nt=Nt, dt=dt);
                    pressure3Dx = squeeze(solver3Dx.pressure(:, end/2, end/2));
                    density3Dx = squeeze(solver3Dx.densitySplit(:, end/2, end/2, 1));
                    velocity3Dx = squeeze(solver3Dx.velocity(:, end/2, end/2, 1));

                    testCase.verifyThat(pressure3Dx, IsEqualTo(pressure1D, "Within", tol)); %Failed here in case 1 (none) 2.03e-6 error at peak
                    testCase.verifyThat(density3Dx,  IsEqualTo(density1D,  "Within", tol));
                    testCase.verifyThat(velocity3Dx, IsEqualTo(velocity1D, "Within", tol));

                    % 3D-y simulation
                    kgrid3Dy = Grid([Nlat, Nax, Nlat], dx, [0, pmlSize, 0]);
                    if EquationType==2 && Cases==5
                        coe=10*ones(Nlat,Nax,Nlat);
                        coe(:,floor(Nax/3):floor(2*Nax/3),:)=15;
                    end
                    medium3Dy = AcousticMedium(kgrid3Dy);
                    medium3Dy.soundSpeed = c0;
                    medium3Dy.density = rho0;
                    medium3Dy.absorptionPower=pow;
                    medium3Dy.absorptionCoeff=coe;
                    medium3Dy.absorptionType=typ;
                    source3Dy = AcousticSource(kgrid3Dy);
                    source3Dy.initialPressure = repmat(reshape(source1D.initialPressure, 1, [], 1), [Nlat, 1, Nlat]);
                    solver3Dy = SolverType(kgrid3Dy, medium3Dy, source3Dy, [], settings);
                    solver3Dy.run(Nt=Nt, dt=dt);
                    pressure3Dy = reshape(squeeze(solver3Dy.pressure(end/2, :, end/2)), [], 1, 1);
                    density3Dy = reshape(squeeze(solver3Dy.densitySplit(end/2, :, end/2, 2)), [], 1, 1);
                    velocity3Dy = reshape(squeeze(solver3Dy.velocity(end/2, :, end/2, 2)), [], 1, 1);

                    testCase.verifyThat(pressure3Dy, IsEqualTo(pressure1D, "Within", tol));
                    testCase.verifyThat(density3Dy,  IsEqualTo(density1D,  "Within", tol));
                    testCase.verifyThat(velocity3Dy, IsEqualTo(velocity1D, "Within", tol));

                    % 3D-z simulation
                    kgrid3Dz = Grid([Nlat, Nlat, Nax], dx, [0, 0, pmlSize]);
                    if EquationType==2 && Cases==5
                        coe=10*ones(Nlat,Nlat,Nax);
                        coe(:,:,floor(Nax/3):floor(2*Nax/3))=15;
                    end
                    medium3Dz = AcousticMedium(kgrid3Dz);
                    medium3Dz.soundSpeed = c0;
                    medium3Dz.density = rho0;
                    medium3Dz.absorptionPower=pow;
                    medium3Dz.absorptionCoeff=coe;
                    medium3Dz.absorptionType=typ;
                    source3Dz = AcousticSource(kgrid3Dz);
                    source3Dz.initialPressure = repmat(reshape(source1D.initialPressure, 1, 1, []), [Nlat, Nlat, 1]);
                    solver3Dz = SolverType(kgrid3Dz, medium3Dz, source3Dz, [], settings);
                    solver3Dz.run(Nt=Nt, dt=dt);
                    pressure3Dz = reshape(squeeze(solver3Dz.pressure(end/2, end/2, :)), [], 1, 1);
                    density3Dz = reshape(squeeze(solver3Dz.densitySplit(end/2, end/2, :, 3)), [], 1, 1);
                    velocity3Dz = reshape(squeeze(solver3Dz.velocity(end/2, end/2, :, 3)), [], 1, 1);

                    testCase.verifyThat(pressure3Dz, IsEqualTo(pressure1D, "Within", tol));
                    testCase.verifyThat(density3Dz,  IsEqualTo(density1D,  "Within", tol));
                    testCase.verifyThat(velocity3Dz, IsEqualTo(velocity1D, "Within", tol));

                    % Re-create 1D solver without settings input to hit default
                    % settings LOC.
                    % SolverType(kgrid1D, medium1D, source1D, []);

                    figure(1)
                    close
                    Cases=Cases+1;
                end
            end

        end
    end
end

