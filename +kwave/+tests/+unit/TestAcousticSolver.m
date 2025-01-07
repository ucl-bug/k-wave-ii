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
%   1D. Performed both with constant and nonconstant gridfield variables.
% * Tests that the simulations produce the same results as the legacy code.
% * Verfifies than the simulations produce the same result when using the
%   medium class or acoustic medium class

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
            Nax = 256;
            Nlat = 16;
            dx = 4e-3;
            c0 = 1500;
            rho0 = 1000;
            alpha0=10;
            pmlSize = 20;
            CFL = 0.5;
            Nt = 150;
            dt = CFL * dx / c0;

            % Settings.
            settings = Settings;
            settings.plotSimulation = 'off';

            % Construct Mediums

            kgrid1D = Grid(Nax, dx, pmlSize);
            medium1D = AcousticMedium(kgrid1D);
            source1D = AcousticSource(kgrid1D);
            source1D.initialPressure = exp( -(kgrid1D.xVec - 25e-3).^2 ./ (5 * kgrid1D.dx).^2 );

            kgrid2Dx = Grid([Nax, Nlat], dx, [pmlSize, 0]);
            medium2Dx = AcousticMedium(kgrid2Dx);
            source2Dx = AcousticSource(kgrid2Dx);
            source2Dx.initialPressure = repmat(source1D.initialPressure, [1, Nlat]);

            kgrid2Dy = Grid([Nlat, Nax], dx, [0, pmlSize]);
            medium2Dy = AcousticMedium(kgrid2Dy);
            source2Dy = AcousticSource(kgrid2Dy);
            source2Dy.initialPressure = repmat(reshape(source1D.initialPressure, 1, []), [Nlat, 1]);

            kgrid3Dx = Grid([Nax, Nlat, Nlat], dx, [pmlSize, 0, 0]);
            medium3Dx = AcousticMedium(kgrid3Dx);
            source3Dx = AcousticSource(kgrid3Dx);
            source3Dx.initialPressure = repmat(source1D.initialPressure, [1, Nlat, Nlat]);

            kgrid3Dy = Grid([Nlat, Nax, Nlat], dx, [0,pmlSize, 0]);
            medium3Dy = AcousticMedium(kgrid3Dy);
            source3Dy = AcousticSource(kgrid3Dy);
            source3Dy.initialPressure = repmat(reshape(source1D.initialPressure, 1, [], 1), [Nlat, 1, Nlat]);

            kgrid3Dz = Grid([Nlat, Nlat, Nax], dx, [0, 0, pmlSize]);
            medium3Dz = AcousticMedium(kgrid3Dz);
            source3Dz = AcousticSource(kgrid3Dz);
            source3Dz.initialPressure = repmat(reshape(source1D.initialPressure, 1, 1, []), [Nlat, Nlat, 1]);

            % Begin Case Types
            for Type=1:4
                disp({'Problem Type : ' Type})
                if Type==1 % case 1: no absorption
                    absorptionType='off';
                elseif Type==2 % case 2: absorptionPower
                    medium1D.absorptionPower = 1.9;
                    medium2Dx.absorptionPower= 1.9;
                    medium2Dy.absorptionPower= 1.9;
                    medium3Dx.absorptionPower= 1.9;
                    medium3Dy.absorptionPower= 1.9;
                    medium3Dz.absorptionPower= 1.9;
                    absorptionType='on';
                elseif Type==3 % case 3: absorptionPower noAbsorption
                    absorptionType='noAbsorption';
                elseif Type==4 % case 4: absorptionPower noDispersion
                    absorptionType='noDispersion';
                end

                medium1D.soundSpeed  = c0;
                medium1D.density  = rho0;
                medium1D.absorptionCoeff = alpha0;
                medium2Dx.soundSpeed = c0;
                medium2Dx.density = rho0;
                medium2Dx.absorptionCoeff= alpha0;
                medium2Dy.soundSpeed = c0;
                medium2Dy.density = rho0;
                medium2Dy.absorptionCoeff= alpha0;
                medium3Dx.soundSpeed = c0;
                medium3Dx.density = rho0;
                medium3Dx.absorptionCoeff= alpha0;
                medium3Dy.soundSpeed = c0;
                medium3Dy.density = rho0;
                medium3Dy.absorptionCoeff= alpha0;
                medium3Dz.soundSpeed = c0;
                medium3Dz.density = rho0;
                medium3Dz.absorptionCoeff= alpha0;

                for DomainCase=1:7
                    disp({'Domain case : ' DomainCase})

                    if DomainCase==1        % c0 rho0 alpha0 single scalar valued

                    elseif DomainCase==2    % c0 grid fixed value gridsize     | rho0 alpha0 single scalar valued
                        medium1D.soundSpeed  = c0*ones(Nax,1);
                        medium2Dx.soundSpeed = c0*ones(Nax,Nlat);
                        medium2Dy.soundSpeed = c0*ones(Nlat,Nax);
                        medium3Dx.soundSpeed = c0*ones(Nax,Nlat,Nlat);
                        medium3Dy.soundSpeed = c0*ones(Nlat,Nax,Nlat);
                        medium3Dz.soundSpeed = c0*ones(Nlat, Nlat,Nax);
                    elseif DomainCase==3    % rho0 grid fixed value gridsize   | c0 alpha0 single scalar valued
                        medium1D.soundSpeed  = c0;
                        medium2Dx.soundSpeed = c0;
                        medium2Dy.soundSpeed = c0;
                        medium3Dx.soundSpeed = c0;
                        medium3Dy.soundSpeed = c0;
                        medium3Dz.soundSpeed = c0;

                        medium1D.density  = rho0*ones(Nax,1);
                        medium2Dx.density = rho0*ones(Nax,Nlat);
                        medium2Dy.density = rho0*ones(Nlat,Nax);
                        medium3Dx.density = rho0*ones(Nax,Nlat,Nlat);
                        medium3Dy.density = rho0*ones(Nlat,Nax,Nlat);
                        medium3Dz.density = rho0*ones(Nlat, Nlat,Nax);
                    elseif DomainCase==4    % alpha0 grid fixed value gridsize | c0 rho0 single scalar valued
                        medium1D.density  = rho0;
                        medium2Dx.density = rho0;
                        medium2Dy.density = rho0;
                        medium3Dx.density = rho0;
                        medium3Dy.density = rho0;
                        medium3Dz.density = rho0;

                        medium1D.absorptionCoeff  = alpha0*ones(Nax,1);
                        medium2Dx.absorptionCoeff = alpha0*ones(Nax,Nlat);
                        medium2Dy.absorptionCoeff = alpha0*ones(Nlat,Nax);
                        medium3Dx.absorptionCoeff = alpha0*ones(Nax,Nlat,Nlat);
                        medium3Dy.absorptionCoeff = alpha0*ones(Nlat,Nax,Nlat);
                        medium3Dz.absorptionCoeff = alpha0*ones(Nlat, Nlat,Nax);
                    elseif DomainCase==5    % c0 grid heterogeneous     | rho0 alpha0 single scalar valued
                        medium1D.absorptionCoeff  = alpha0;
                        medium2Dx.absorptionCoeff = alpha0;
                        medium2Dy.absorptionCoeff = alpha0;
                        medium3Dx.absorptionCoeff = alpha0;
                        medium3Dy.absorptionCoeff = alpha0;
                        medium3Dz.absorptionCoeff = alpha0;

                        medium1D.soundSpeed  = c0*ones(Nax,1);
                        medium1D.soundSpeed(floor(2*Nax/5):floor(3*Nax/5))=c0/0.9;
                        medium2Dx.soundSpeed = c0*ones(Nax,Nlat);
                        medium2Dx.soundSpeed(floor(2*Nax/5):floor(3*Nax/5),:)=c0/0.9;
                        medium2Dy.soundSpeed = c0*ones(Nlat,Nax);
                        medium2Dy.soundSpeed(:,floor(2*Nax/5):floor(3*Nax/5))=c0/0.9;
                        medium3Dx.soundSpeed = c0*ones(Nax,Nlat,Nlat);
                        medium3Dx.soundSpeed(floor(2*Nax/5):floor(3*Nax/5),:,:)=c0/0.9;
                        medium3Dy.soundSpeed = c0*ones(Nlat,Nax,Nlat);
                        medium3Dy.soundSpeed(:,floor(2*Nax/5):floor(3*Nax/5),:)=c0/0.9;
                        medium3Dz.soundSpeed = c0*ones(Nlat, Nlat,Nax);
                        medium3Dz.soundSpeed(:,:,floor(2*Nax/5):floor(3*Nax/5))=c0/0.9;
                    elseif DomainCase==6    % rho0 grid heterogeneous   | c0 alpha0 single scalar valued
                        medium1D.soundSpeed  = c0;
                        medium2Dx.soundSpeed = c0;
                        medium2Dy.soundSpeed = c0;
                        medium3Dx.soundSpeed = c0;
                        medium3Dy.soundSpeed = c0;
                        medium3Dz.soundSpeed = c0;

                        medium1D.density  = rho0*ones(Nax,1);
                        medium1D.density(floor(2*Nax/5):floor(3*Nax/5))=rho0/1.1;
                        medium2Dx.density = rho0*ones(Nax,Nlat);
                        medium2Dx.density(floor(2*Nax/5):floor(3*Nax/5),:)=rho0/1.1;
                        medium2Dy.density = rho0*ones(Nlat,Nax);
                        medium2Dy.density(:,floor(2*Nax/5):floor(3*Nax/5))=rho0/1.1;
                        medium3Dx.density = rho0*ones(Nax,Nlat,Nlat);
                        medium3Dx.density(floor(2*Nax/5):floor(3*Nax/5),:,:)=rho0/1.1;
                        medium3Dy.density = rho0*ones(Nlat,Nax,Nlat);
                        medium3Dy.density(:,floor(2*Nax/5):floor(3*Nax/5),:)=rho0/1.1;
                        medium3Dz.density = rho0*ones(Nlat, Nlat,Nax);
                        medium3Dz.density(:,:,floor(2*Nax/5):floor(3*Nax/5))=rho0/1.1;
                    elseif DomainCase==7    % alpha0 grid heterogeneous | c0 rho0 single scalar valued
                        medium1D.density  = rho0;
                        medium2Dx.density = rho0;
                        medium2Dy.density = rho0;
                        medium3Dx.density = rho0;
                        medium3Dy.density = rho0;
                        medium3Dz.density = rho0;

                        medium1D.absorptionCoeff  = alpha0*ones(Nax,1);
                        medium1D.absorptionCoeff(floor(2*Nax/5):floor(3*Nax/5))=alpha0/1.1;
                        medium2Dx.absorptionCoeff = alpha0*ones(Nax,Nlat);
                        medium2Dx.absorptionCoeff(floor(2*Nax/5):floor(3*Nax/5),:)=alpha0/1.1;
                        medium2Dy.absorptionCoeff = alpha0*ones(Nlat,Nax);
                        medium2Dy.absorptionCoeff(:,floor(2*Nax/5):floor(3*Nax/5))=alpha0/1.1;
                        medium3Dx.absorptionCoeff = alpha0*ones(Nax,Nlat,Nlat);
                        medium3Dx.absorptionCoeff(floor(2*Nax/5):floor(3*Nax/5),:,:)=alpha0/1.1;
                        medium3Dy.absorptionCoeff = alpha0*ones(Nlat,Nax,Nlat);
                        medium3Dy.absorptionCoeff(:,floor(2*Nax/5):floor(3*Nax/5),:)=alpha0/1.1;
                        medium3Dz.absorptionCoeff = alpha0*ones(Nlat, Nlat,Nax);
                        medium3Dz.absorptionCoeff(:,:,floor(2*Nax/5):floor(3*Nax/5))=alpha0/1.1;
                    end

                    % Running Simulations

                    %Reference Solution
                    solver1D = AcousticSolver(kgrid1D, medium1D, source1D, [], settings);
                    solver1D.absorptionType=absorptionType;
                    solver1D.run(Nt=Nt, dt=dt);
                    pressure1D = solver1D.pressure;
                    density1D = solver1D.densitySplit;
                    velocity1D = solver1D.velocity;

                    solver2Dx = AcousticSolver(kgrid2Dx, medium2Dx, source2Dx, [], settings);
                    solver2Dx.absorptionType=absorptionType;
                    solver2Dx.run(Nt=Nt, dt=dt);
                    pressure2Dx = squeeze(solver2Dx.pressure(:, end/2));
                    density2Dx = squeeze(solver2Dx.densitySplit(:, end/2, 1, 1));
                    velocity2Dx = squeeze(solver2Dx.velocity(:, end/2, 1, 1));

                    solver2Dy = AcousticSolver(kgrid2Dy, medium2Dy, source2Dy, [], settings);
                    solver2Dy.absorptionType=absorptionType;
                    solver2Dy.run(Nt=Nt, dt=dt);
                    pressure2Dy = reshape(squeeze(solver2Dy.pressure(end/2, :)), [], 1);
                    density2Dy = reshape(squeeze(solver2Dy.densitySplit(end/2, :, 1, 2)), [], 1);
                    velocity2Dy = reshape(squeeze(solver2Dy.velocity(end/2, :, 1, 2)), [], 1);

                    solver3Dx = AcousticSolver(kgrid3Dx, medium3Dx, source3Dx, [], settings); % Failed 1-5
                    solver3Dx.absorptionType=absorptionType;
                    solver3Dx.run(Nt=Nt, dt=dt);
                    pressure3Dx = squeeze(solver3Dx.pressure(:, end/2, end/2));
                    density3Dx = squeeze(solver3Dx.densitySplit(:, end/2, end/2, 1));
                    velocity3Dx = squeeze(solver3Dx.velocity(:, end/2, end/2, 1));

                    solver3Dy = AcousticSolver(kgrid3Dy, medium3Dy, source3Dy, [], settings);
                    solver3Dy.absorptionType=absorptionType;
                    solver3Dy.run(Nt=Nt, dt=dt);
                    pressure3Dy = reshape(squeeze(solver3Dy.pressure(end/2, :, end/2)), [], 1, 1);
                    density3Dy = reshape(squeeze(solver3Dy.densitySplit(end/2, :, end/2, 2)), [], 1, 1);
                    velocity3Dy = reshape(squeeze(solver3Dy.velocity(end/2, :, end/2, 2)), [], 1, 1);

                    solver3Dz = AcousticSolver(kgrid3Dz, medium3Dz, source3Dz, [], settings);
                    solver3Dz.absorptionType=absorptionType;
                    solver3Dz.run(Nt=Nt, dt=dt);
                    pressure3Dz = reshape(squeeze(solver3Dz.pressure(end/2, end/2, :)), [], 1, 1);
                    density3Dz = reshape(squeeze(solver3Dz.densitySplit(end/2, end/2, :, 3)), [], 1, 1);
                    velocity3Dz = reshape(squeeze(solver3Dz.velocity(end/2, end/2, :, 3)), [], 1, 1);

                    % Testing
                    testCase.verifyThat(pressure2Dx, IsEqualTo(pressure1D, "Within", tol)); %
                    testCase.verifyThat(density2Dx,  IsEqualTo(density1D,  "Within", tol)); %
                    testCase.verifyThat(velocity2Dx, IsEqualTo(velocity1D, "Within", tol)); %

                    testCase.verifyThat(pressure2Dy, IsEqualTo(pressure1D, "Within", tol)); %
                    testCase.verifyThat(density2Dy,  IsEqualTo(density1D,  "Within", tol)); %
                    testCase.verifyThat(velocity2Dy, IsEqualTo(velocity1D, "Within", tol)); %

                    testCase.verifyThat(pressure3Dx, IsEqualTo(pressure1D, "Within", tol)); %
                    testCase.verifyThat(density3Dx,  IsEqualTo(density1D,  "Within", tol)); %
                    testCase.verifyThat(velocity3Dx, IsEqualTo(velocity1D, "Within", tol)); %

                    testCase.verifyThat(pressure3Dy, IsEqualTo(pressure1D, "Within", tol)); %
                    testCase.verifyThat(density3Dy,  IsEqualTo(density1D,  "Within", tol)); %
                    testCase.verifyThat(velocity3Dy, IsEqualTo(velocity1D, "Within", tol)); %

                    testCase.verifyThat(pressure3Dz, IsEqualTo(pressure1D, "Within", tol)); %
                    testCase.verifyThat(density3Dz,  IsEqualTo(density1D,  "Within", tol)); %
                    testCase.verifyThat(velocity3Dz, IsEqualTo(velocity1D, "Within", tol)); %


                end
            end
            % Re-create 1D solver without settings input to hit default
            % settings LOC.
            AcousticSolver(kgrid1D, medium1D, source1D, []);
        end

        %Test against legacy code with and without absorption
        function testAgainstLegacyAbsorption(testCase)

            import kwave.toolbox.*
            import kwave.legacy.*
            import matlab.unittest.constraints.IsEqualTo

            % Define tolerance for field comparisons.
            tol = matlab.unittest.constraints.AbsoluteTolerance(single(1e-6));

            % Test properties.
            Nax = 256;
            Nlat = 16;
            dx = 4e-3;
            c0 = 1500;
            rho0 = 1000;
            alpha0=10;
            pmlSize = 20;
            CFL = 0.25;
            Nt = 150;
            dt = CFL * dx / c0;

            % New setup
            kgrid1D = Grid(Nax, dx, pmlSize);
            medium1D = AcousticMedium(kgrid1D);
            medium1D.soundSpeed  = c0;
            medium1D.density  = rho0;
            source1D = AcousticSource(kgrid1D);
            source1D.initialPressure = exp( -(kgrid1D.xVec - 25e-3).^2 ./ (5 * kgrid1D.dx).^2 );
            settings = Settings;
            settings.plotSimulation = 'off';
            solver1D = AcousticSolver(kgrid1D, medium1D, source1D, [], settings);
            solver1D.run(Nt=Nt, dt=dt);
            % Legacy setup
            kgrid1DL=kWaveGrid(Nax,dx);
            kgrid1DL.setTime(Nt, dt)
            source1DL.p0= exp( -((kgrid1DL.x_vec - 25e-3 ).^2) ./ ( 5* kgrid1DL.dx).^2 ) ;
            medium1DL.sound_speed=c0;
            medium1DL.density=rho0;
            sensor1DL.record={'p_final'};
            sensor_data1 = kspaceFirstOrder1D(kgrid1DL, medium1DL, source1DL, sensor1DL,'PMLInside',false,'Smooth',false);
            testCase.verifyThat(solver1D.pressure, IsEqualTo(single(sensor_data1.p_final), "Within", tol));

            % Staggered Density
            rho0M  = rho0*ones(Nax,1);
            rho0M(floor(2*Nax/5):floor(3*Nax/5))=rho0/1.5;
            medium1D.density  = rho0M;
            medium1DL.density=rho0M;
            solver1D = AcousticSolver(kgrid1D, medium1D, source1D, [], settings);
            solver1D.run(Nt=Nt, dt=dt);
            sensor_data1 = kspaceFirstOrder1D(kgrid1DL, medium1DL, source1DL, sensor1DL,'PMLInside',false,'Smooth',false);
            testCase.verifyThat(solver1D.pressure, IsEqualTo(single(sensor_data1.p_final), "Within", tol));

            % PowerLaw
            medium1D.absorptionCoeff  = alpha0;
            medium1DL.alpha_coeff  = alpha0;
            medium1D.absorptionPower  = 1.9;
            medium1DL.alpha_power  = 1.9;
            solver1D = AcousticSolver(kgrid1D, medium1D, source1D, [], settings);
            solver1D.absorptionType="on";
            solver1D.run(Nt=Nt, dt=dt);
            sensor_data1 = kspaceFirstOrder1D(kgrid1DL, medium1DL, source1DL, sensor1DL,'PMLInside',false,'Smooth',false);
            testCase.verifyThat(solver1D.pressure, IsEqualTo(single(sensor_data1.p_final), "Within", tol));

            % 2D case no dispersion
            kgrid2Dx = Grid([Nax, Nlat], dx, [pmlSize, 0]);
            medium2Dx = AcousticMedium(kgrid2Dx);
            source2Dx = AcousticSource(kgrid2Dx);
            source2Dx.initialPressure = repmat(source1D.initialPressure, [1, Nlat]);
            kgrid2Dy = Grid([Nlat, Nax], dx, [0, pmlSize]);
            medium2Dy = AcousticMedium(kgrid2Dy);
            source2Dy = AcousticSource(kgrid2Dy);
            source2Dy.initialPressure = repmat(reshape(source1D.initialPressure, 1, []), [Nlat, 1]);
            medium2Dx.soundSpeed = c0;
            medium2Dx.density = rho0;
            medium2Dx.absorptionCoeff= alpha0;
            medium2Dx.absorptionPower= 1.9;
            medium2Dy.soundSpeed = c0;
            medium2Dy.density = rho0;
            medium2Dy.absorptionCoeff= alpha0;
            medium2Dy.absorptionPower= 1.9;
            solver2Dx = AcousticSolver(kgrid2Dx, medium2Dx, source2Dx, [], settings);
            solver2Dx.absorptionType='noDispersion';
            solver2Dx.run(Nt=Nt, dt=dt);
            solver2Dy = AcousticSolver(kgrid2Dy, medium2Dy, source2Dy, [], settings);
            solver2Dy.absorptionType='noAbsorption';
            solver2Dy.run(Nt=Nt, dt=dt);

            kgrid2DxL=kWaveGrid(Nax,dx,Nlat,dx);
            kgrid2DxL.setTime(Nt, dt)
            source2DxL.p0=  repmat(source1D.initialPressure, [1, Nlat]);
            medium2DxL.sound_speed=c0;
            medium2DxL.density=rho0;
            medium2DxL.alpha_power  = 1.9;
            medium2DxL.alpha_coeff=alpha0;
            sensor2DxL.record={'p_final'};
            medium2DxL.alpha_mode='no_dispersion';
            sensor_data2x = kspaceFirstOrder2D(kgrid2DxL, medium2DxL, source2DxL, sensor2DxL,'PMLInside',false,'Smooth',false,'PMLSize',[pmlSize,0]);
            kgrid2DyL=kWaveGrid(Nlat,dx,Nax,dx);
            kgrid2DyL.setTime(Nt, dt)
            source2DyL.p0= repmat(reshape(source1D.initialPressure, 1, []), [Nlat, 1]);
            medium2DyL.sound_speed=c0;
            medium2DyL.density=rho0;
            medium2DyL.alpha_power  = 1.9;
            medium2DyL.alpha_coeff=alpha0;
            sensor2DyL.record={'p_final'};
            medium2DyL.alpha_mode='no_absorption';
            sensor_data2y = kspaceFirstOrder2D(kgrid2DyL, medium2DyL, source2DyL, sensor2DyL,'PMLInside',false,'Smooth',false,'PMLSize',[0,pmlSize]);

            testCase.verifyThat(solver2Dx.pressure, IsEqualTo(single(sensor_data2x.p_final), "Within", tol));
            testCase.verifyThat(solver2Dy.pressure, IsEqualTo(single(sensor_data2y.p_final), "Within", tol));

            kgrid3Dx = Grid([Nax, Nlat,Nlat], dx, [pmlSize, 0,0]);
            medium3Dx = AcousticMedium(kgrid3Dx);
            source3Dx = AcousticSource(kgrid3Dx);
            source3Dx.initialPressure = repmat(source1D.initialPressure, [1, Nlat, Nlat]);
            medium3Dx.soundSpeed = c0;
            medium3Dx.density = rho0;
            medium3Dx.absorptionCoeff= alpha0*0.9;
            medium3Dx.absorptionPower= 1.2;
            solver3Dx = AcousticSolver(kgrid3Dx, medium3Dx, source3Dx, [], settings);
            solver3Dx.absorptionType="on";
            solver3Dx.run(Nt=Nt, dt=dt);

            kgrid3DxL=kWaveGrid(Nax,dx,Nlat,dx,Nlat,dx);
            kgrid3DxL.setTime(Nt, dt)
            source3DxL.p0=  repmat(source1D.initialPressure, [1, Nlat, Nlat]);
            medium3DxL.sound_speed=c0;
            medium3DxL.density=rho0;
            medium3DxL.alpha_power  = 1.2;
            medium3DxL.alpha_coeff=alpha0*0.9;
            sensor3DxL.record={'p_final'};
            sensor_data3x = kspaceFirstOrder3D(kgrid3DxL, medium3DxL, source3DxL, sensor3DxL,'PMLInside',false,'Smooth',false,'PMLSize',[pmlSize,0,0]);
            testCase.verifyThat(solver3Dx.pressure, IsEqualTo(single(sensor_data3x.p_final), "Within", tol));
        end

        function testTimeRestarting(testCase)
            % This test only concerns the no absoroption case in 1D,2D & 3D
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
            alpha0=10;
            pmlSize = 20;
            CFL = 0.3; % Smaller CFL for 2D and 3D, solutions still accurate with higher but not to Tol
            Nt = 150;
            dt = CFL * dx / c0;

            % Settings.
            settings = Settings;
            settings.plotSimulation = 'off';

            % Construct Mediums

            kgrid1D = Grid(Nax, dx, pmlSize);
            medium1D = AcousticMedium(kgrid1D);
            source1D = AcousticSource(kgrid1D);
            source1D.initialPressure = exp( -(kgrid1D.xVec - 25e-3).^2 ./ (5 * kgrid1D.dx).^2 );

            kgrid2Dx = Grid([Nax, Nlat], dx, [pmlSize, 0]);
            medium2Dx = AcousticMedium(kgrid2Dx);
            source2Dx = AcousticSource(kgrid2Dx);
            source2Dx.initialPressure = repmat(source1D.initialPressure, [1, Nlat]);

            kgrid2Dy = Grid([Nlat, Nax], dx, [0, pmlSize]);
            medium2Dy = AcousticMedium(kgrid2Dy);
            source2Dy = AcousticSource(kgrid2Dy);
            source2Dy.initialPressure = repmat(reshape(source1D.initialPressure, 1, []), [Nlat, 1]);

            kgrid3Dx = Grid([Nax, Nlat, Nlat], dx, [pmlSize, 0, 0]);
            medium3Dx = AcousticMedium(kgrid3Dx);
            source3Dx = AcousticSource(kgrid3Dx);
            source3Dx.initialPressure = repmat(source1D.initialPressure, [1, Nlat, Nlat]);

            kgrid3Dy = Grid([Nlat, Nax, Nlat], dx, [0,pmlSize, 0]);
            medium3Dy = AcousticMedium(kgrid3Dy);
            source3Dy = AcousticSource(kgrid3Dy);
            source3Dy.initialPressure = repmat(reshape(source1D.initialPressure, 1, [], 1), [Nlat, 1, Nlat]);

            kgrid3Dz = Grid([Nlat, Nlat, Nax], dx, [0, 0, pmlSize]);
            medium3Dz = AcousticMedium(kgrid3Dz);
            source3Dz = AcousticSource(kgrid3Dz);
            source3Dz.initialPressure = repmat(reshape(source1D.initialPressure, 1, 1, []), [Nlat, Nlat, 1]);

            medium1D.soundSpeed  = c0;
            medium1D.density  = rho0;
            medium1D.absorptionCoeff = alpha0;
            medium2Dx.soundSpeed = c0;
            medium2Dx.density = rho0;
            medium2Dx.absorptionCoeff= alpha0;
            medium2Dy.soundSpeed = c0;
            medium2Dy.density = rho0;
            medium2Dy.absorptionCoeff= alpha0;
            medium3Dx.soundSpeed = c0;
            medium3Dx.density = rho0;
            medium3Dx.absorptionCoeff= alpha0;
            medium3Dy.soundSpeed = c0;
            medium3Dy.density = rho0;
            medium3Dy.absorptionCoeff= alpha0;
            medium3Dz.soundSpeed = c0;
            medium3Dz.density = rho0;
            medium3Dz.absorptionCoeff= alpha0;

            %Reference Solution
            solver1DRef = AcousticSolver(kgrid1D, medium1D, source1D, [], settings);
            solver1DRef.run(Nt=Nt, dt=dt);
            pressure1DRef = solver1DRef.pressure;
            density1DRef = solver1DRef.densitySplit;
            velocity1DRef = solver1DRef.velocity;

            % 1D Case uses smaller time steps
            solver1D = AcousticSolver(kgrid1D, medium1D, source1D, [], settings);
            solver1D.run(Nt=2*Nt/3, dt=dt);
            solver1D.run(Nt=2*Nt/3, dt=dt/2);
            pressure1D = solver1D.pressure;
            density1D = solver1D.densitySplit;
            velocity1D = solver1D.velocity;

            % 2D Case use larger time steps
            solver2Dx = AcousticSolver(kgrid2Dx, medium2Dx, source2Dx, [], settings);
            solver2Dx.run(Nt=2*Nt/3, dt=dt);
            solver2Dx.run(Nt=Nt/6, dt=2*dt);
            pressure2Dx = squeeze(solver2Dx.pressure(:, end/2));
            density2Dx = squeeze(solver2Dx.densitySplit(:, end/2, 1, 1));
            velocity2Dx = squeeze(solver2Dx.velocity(:, end/2, 1, 1));

            solver2Dy = AcousticSolver(kgrid2Dy, medium2Dy, source2Dy, [], settings);
            solver2Dy.run(Nt=2*Nt/3, dt=dt);
            solver2Dy.run(Nt=Nt/6, dt=2*dt);
            pressure2Dy = reshape(squeeze(solver2Dy.pressure(end/2, :)), [], 1);
            density2Dy = reshape(squeeze(solver2Dy.densitySplit(end/2, :, 1, 2)), [], 1);
            velocity2Dy = reshape(squeeze(solver2Dy.velocity(end/2, :, 1, 2)), [], 1);

            %3D Case swap between smaller, same and larger
            solver3Dx = AcousticSolver(kgrid3Dx, medium3Dx, source3Dx, [], settings);
            solver3Dx.run(Nt=2*Nt/3, dt=dt);
            solver3Dx.run(Nt=Nt/6, dt=2*dt);
            pressure3Dx = squeeze(solver3Dx.pressure(:, end/2, end/2));
            density3Dx = squeeze(solver3Dx.densitySplit(:, end/2, end/2, 1));
            velocity3Dx = squeeze(solver3Dx.velocity(:, end/2, end/2, 1));

            solver3Dy = AcousticSolver(kgrid3Dy, medium3Dy, source3Dy, [], settings);
            solver3Dy.run(Nt=2*Nt/3, dt=dt);
            solver3Dy.run(Nt=Nt/3, dt=dt);
            pressure3Dy = reshape(squeeze(solver3Dy.pressure(end/2, :, end/2)), [], 1, 1);
            density3Dy = reshape(squeeze(solver3Dy.densitySplit(end/2, :, end/2, 2)), [], 1, 1);
            velocity3Dy = reshape(squeeze(solver3Dy.velocity(end/2, :, end/2, 2)), [], 1, 1);

            solver3Dz = AcousticSolver(kgrid3Dz, medium3Dz, source3Dz, [], settings);
            solver3Dz.run(Nt=2*Nt/3, dt=dt);
            solver3Dz.run(Nt=2*Nt/3, dt=dt/2);
            pressure3Dz = reshape(squeeze(solver3Dz.pressure(end/2, end/2, :)), [], 1, 1);
            density3Dz = reshape(squeeze(solver3Dz.densitySplit(end/2, end/2, :, 3)), [], 1, 1);
            velocity3Dz = reshape(squeeze(solver3Dz.velocity(end/2, end/2, :, 3)), [], 1, 1);

            % Testing
            testCase.verifyThat(pressure1DRef, IsEqualTo(pressure1D, "Within", tol)); %
            testCase.verifyThat(density1DRef,  IsEqualTo(density1D,  "Within", tol)); %
            testCase.verifyThat(velocity1DRef, IsEqualTo(velocity1D, "Within", tol)); %

            testCase.verifyThat(pressure2Dx, IsEqualTo(pressure1DRef, "Within", tol)); %
            testCase.verifyThat(density2Dx,  IsEqualTo(density1DRef,  "Within", tol)); %
            testCase.verifyThat(velocity2Dx, IsEqualTo(velocity1DRef, "Within", tol)); %

            testCase.verifyThat(pressure2Dy, IsEqualTo(pressure1DRef, "Within", tol)); %
            testCase.verifyThat(density2Dy,  IsEqualTo(density1DRef,  "Within", tol)); %
            testCase.verifyThat(velocity2Dy, IsEqualTo(velocity1DRef, "Within", tol)); %

            testCase.verifyThat(pressure3Dx, IsEqualTo(pressure1DRef, "Within", tol)); %
            testCase.verifyThat(density3Dx,  IsEqualTo(density1DRef,  "Within", tol)); %
            testCase.verifyThat(velocity3Dx, IsEqualTo(velocity1DRef, "Within", tol)); %

            testCase.verifyThat(pressure3Dy, IsEqualTo(pressure1DRef, "Within", tol)); %
            testCase.verifyThat(density3Dy,  IsEqualTo(density1DRef,  "Within", tol)); %
            testCase.verifyThat(velocity3Dy, IsEqualTo(velocity1DRef, "Within", tol)); %

            testCase.verifyThat(pressure3Dz, IsEqualTo(pressure1D, "Within", tol)); %
            testCase.verifyThat(density3Dz,  IsEqualTo(density1D,  "Within", tol)); %
            testCase.verifyThat(velocity3Dz, IsEqualTo(velocity1D, "Within", tol)); %

            % test to show time restart works with change powerlaw
            medium1D.absorptionPower=1.1;
            medium1D.absorptionCoeff=0.5;
            solver1DP= AcousticSolver(kgrid1D, medium1D, source1D, [], settings);
            solver1DP.run(Nt=2, dt=dt);
            solver1DP.run(Nt=2, dt=2*dt);
        end

         % Test that the medium class returns the smae values as the
        % acoustic medium class.
        function testMediumAgreement(testCase)

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
            alpha0=10;
            alphay=1.9;
            pmlSize = 20;
            CFL = 0.25;
            Nt = 150;
            dt = CFL * dx / c0;

            kgrid1D = Grid(Nax, dx, pmlSize);
            % Construct Acoustic Medium
            medium1D = AcousticMedium(kgrid1D);
            medium1D.soundSpeed  = c0;
            medium1D.density  = rho0;
            medium1D.absorptionPower=alphay;
            medium1D.absorptionCoeff=alpha0;
            % Construct Medium
            mediumMaterial1D=Medium(kgrid1D);
            mediumMaterial1D.materialIDGrid = 1;
            %
            source1D = AcousticSource(kgrid1D);
            source1D.initialPressure = exp( -(kgrid1D.xVec - 25e-3).^2 ./ (5 * kgrid1D.dx).^2 );
            settings = Settings;
            settings.plotSimulation = 'off';
            settings2 = Settings;
            settings2.plotSimulation = 'on';
            %
            solver1DA = AcousticSolver(kgrid1D, medium1D, source1D, [], settings);
            solver1DA.run(Nt=Nt, dt=dt);
            solver1DB = AcousticSolver(kgrid1D, mediumMaterial1D, source1D, [], settings);
            solver1DB.run(Nt=Nt, dt=dt);
            testCase.verifyThat(solver1DA.pressure, IsEqualTo(solver1DB.pressure, "Within", tol));
            
            kgrid2Dx = Grid([Nax,Nlat], dx, [pmlSize,0]);
            source2Dx = AcousticSource(kgrid2Dx);
            source2Dx.initialPressure = repmat(source1D.initialPressure, [1, Nlat]);
            % Construct Acoustic Medium
            medium2Dx = AcousticMedium(kgrid2Dx);
            medium2Dx.soundSpeed  = c0;
            medium2Dx.density  = rho0;
            medium2Dx.absorptionPower=alphay;
            medium2Dx.absorptionCoeff=alpha0;
            % Construct Medium
            mediumMaterial2Dx=Medium(kgrid2Dx);
            mediumMaterial2Dx.materialIDGrid = 1;
            %
            solver2DxA = AcousticSolver(kgrid2Dx, medium2Dx, source2Dx, [], settings);
            solver2DxB = AcousticSolver(kgrid2Dx, mediumMaterial2Dx, source2Dx, [], settings);
            solver2DxA.absorptionType='on';
            solver2DxB.absorptionType='on';
            solver2DxA.run(Nt=Nt, dt=dt);
            solver2DxB.run(Nt=Nt, dt=dt);
            testCase.verifyThat(solver2DxA.pressure, IsEqualTo(solver2DxB.pressure, "Within", tol));
            %
            kgrid2Dy = Grid([Nlat,Nax], dx, [0,pmlSize]);
            source2Dy = AcousticSource(kgrid2Dy);
            source2Dy.initialPressure = repmat(reshape(source1D.initialPressure, 1, []), [Nlat, 1]);
            % Construct Acoustic Medium
            medium2Dy = AcousticMedium(kgrid2Dy);
            medium2Dy.soundSpeed  = c0;
            medium2Dy.density  = rho0;
            medium2Dy.absorptionPower=alphay;
            medium2Dy.absorptionCoeff=alpha0;
            % Construct Medium
            mediumMaterial2Dy=Medium(kgrid2Dy);
            mediumMaterial2Dy.materialIDGrid = 1;
            %
            solver2DyA = AcousticSolver(kgrid2Dy, medium2Dy, source2Dy, [], settings);
            solver2DyB = AcousticSolver(kgrid2Dy, mediumMaterial2Dy, source2Dy, [], settings);
            solver2DyA.absorptionType='noDispersion';
            solver2DyB.absorptionType='noDispersion';
            solver2DyA.run(Nt=Nt, dt=dt);
            solver2DyB.run(Nt=Nt, dt=dt);
            testCase.verifyThat(solver2DyA.pressure, IsEqualTo(solver2DyB.pressure, "Within", tol));
            %
            kgrid3Dx = Grid([Nax,Nlat,Nlat], dx, [pmlSize,0,0]);
            source3Dx = AcousticSource(kgrid3Dx);
            source3Dx.initialPressure = repmat(source1D.initialPressure, [1, Nlat, Nlat]);
            % Construct Acoustic Medium
            medium3Dx = AcousticMedium(kgrid3Dx);
            medium3Dx.soundSpeed  = c0;
            medium3Dx.density  = rho0;
            medium3Dx.absorptionPower=alphay;
            medium3Dx.absorptionCoeff=alpha0;
            % Construct Medium
            mediumMaterial3Dx=Medium(kgrid3Dx);
            mediumMaterial3Dx.materialIDGrid = 1;
            %
            solver3DxA = AcousticSolver(kgrid3Dx, medium3Dx, source3Dx, [], settings);
            solver3DxB = AcousticSolver(kgrid3Dx, mediumMaterial3Dx, source3Dx, [], settings);
            solver3DxA.absorptionType='noAbsorption';
            solver3DxB.absorptionType='noAbsorption';
            solver3DxA.run(Nt=Nt, dt=dt);
            solver3DxB.run(Nt=Nt, dt=dt);
            testCase.verifyThat(solver3DxA.pressure, IsEqualTo(solver3DxB.pressure, "Within", tol));
            %
            kgrid3Dy = Grid([Nlat,Nax,Nlat], dx, [0,pmlSize,0]);
            source3Dy = AcousticSource(kgrid3Dy);
            source3Dy.initialPressure = repmat(reshape(source1D.initialPressure, 1, [], 1), [Nlat, 1, Nlat]);
            % Construct Acoustic Medium
            medium3Dy = AcousticMedium(kgrid3Dy);
            medium3Dy.soundSpeed  = c0;
            medium3Dy.density  = rho0;
            medium3Dy.absorptionPower=alphay;
            medium3Dy.absorptionCoeff=alpha0;
            % Construct Medium
            mediumMaterial3Dy=Medium(kgrid3Dy);
            mediumMaterial3Dy.materialIDGrid = ones(kgrid3Dy.gridSize);
            %
            solver3DyA = AcousticSolver(kgrid3Dy, medium3Dy, source3Dy, [], settings);
            solver3DyB = AcousticSolver(kgrid3Dy, mediumMaterial3Dy, source3Dy, [], settings);
            solver3DyA.run(Nt=Nt, dt=dt);
            solver3DyB.run(Nt=Nt, dt=dt);
            testCase.verifyThat(solver3DyA.pressure, IsEqualTo(solver3DyB.pressure, "Within", tol));
            %
            kgrid3Dz = Grid([Nlat,Nlat,Nax], dx, [0,0,pmlSize]);
            source3Dz = AcousticSource(kgrid3Dz);
            source3Dz.initialPressure = repmat(reshape(source1D.initialPressure, 1, 1, []), [Nlat, Nlat, 1]);
            % Construct Acoustic Medium
            medium3Dz = AcousticMedium(kgrid3Dz);
            medium3Dz.soundSpeed = c0*ones(kgrid3Dz.gridSize);
            medium3Dz.soundSpeed(:,:,ceil(Nax/2):end) = c0/0.9;
            medium3Dz.density  = rho0;
            medium3Dz.absorptionPower=alphay;
            medium3Dz.absorptionCoeff=alpha0;
            % Construct Medium
            mediumMaterial3Dz=Medium(kgrid3Dz);
            mediumMaterial3Dz.materialIDGrid = ones(kgrid3Dz.gridSize);
            mediumMaterial3Dz.materialIDGrid(:,:,ceil(Nax/2):end) = 2;
            %
            solver3DzA = AcousticSolver(kgrid3Dz, medium3Dz, source3Dz, [], settings);
            solver3DzB = AcousticSolver(kgrid3Dz, mediumMaterial3Dz, source3Dz, [], settings);
            solver3DzA.run(Nt=Nt, dt=dt);
            solver3DzB.run(Nt=Nt, dt=dt);
            testCase.verifyThat(solver3DzA.pressure, IsEqualTo(solver3DzB.pressure, "Within", tol));
            % 
        end
    end



end

