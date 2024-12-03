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

                elseif Type==2 % case 2: absorptionPower
                    medium1D.absorptionPower = 1.9;
                    medium2Dx.absorptionPower= 1.9;
                    medium2Dy.absorptionPower= 1.9;
                    medium3Dx.absorptionPower= 1.9;
                    medium3Dy.absorptionPower= 1.9;
                    medium3Dz.absorptionPower= 1.9;
                elseif Type==3 % case 3: absorptionPower noAbsorption
                    medium1D.absorptionType = 'noAbsorption';
                    medium2Dx.absorptionType= 'noAbsorption';
                    medium2Dy.absorptionType= 'noAbsorption';
                    medium3Dx.absorptionType= 'noAbsorption';
                    medium3Dy.absorptionType= 'noAbsorption';
                    medium3Dz.absorptionType= 'noAbsorption';
                elseif Type==4 % case 4: absorptionPower noDispersion
                    medium1D.absorptionType = 'noDispersion';
                    medium2Dx.absorptionType= 'noDispersion';
                    medium2Dy.absorptionType= 'noDispersion';
                    medium3Dx.absorptionType= 'noDispersion';
                    medium3Dy.absorptionType= 'noDispersion';
                    medium3Dz.absorptionType= 'noDispersion';
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
                    solver1D.run(Nt=Nt, dt=dt);
                    pressure1D = solver1D.pressure;
                    density1D = solver1D.densitySplit;
                    velocity1D = solver1D.velocity;

                    solver2Dx = AcousticSolver(kgrid2Dx, medium2Dx, source2Dx, [], settings);
                    solver2Dx.run(Nt=Nt, dt=dt);
                    pressure2Dx = squeeze(solver2Dx.pressure(:, end/2));
                    density2Dx = squeeze(solver2Dx.densitySplit(:, end/2, 1, 1));
                    velocity2Dx = squeeze(solver2Dx.velocity(:, end/2, 1, 1));

                    solver2Dy = AcousticSolver(kgrid2Dy, medium2Dy, source2Dy, [], settings);
                    solver2Dy.run(Nt=Nt, dt=dt);
                    pressure2Dy = reshape(squeeze(solver2Dy.pressure(end/2, :)), [], 1);
                    density2Dy = reshape(squeeze(solver2Dy.densitySplit(end/2, :, 1, 2)), [], 1);
                    velocity2Dy = reshape(squeeze(solver2Dy.velocity(end/2, :, 1, 2)), [], 1);

                    solver3Dx = AcousticSolver(kgrid3Dx, medium3Dx, source3Dx, [], settings); % Failed 1-5
                    solver3Dx.run(Nt=Nt, dt=dt);
                    pressure3Dx = squeeze(solver3Dx.pressure(:, end/2, end/2));
                    density3Dx = squeeze(solver3Dx.densitySplit(:, end/2, end/2, 1));
                    velocity3Dx = squeeze(solver3Dx.velocity(:, end/2, end/2, 1));

                    solver3Dy = AcousticSolver(kgrid3Dy, medium3Dy, source3Dy, [], settings);
                    solver3Dy.run(Nt=Nt, dt=dt);
                    pressure3Dy = reshape(squeeze(solver3Dy.pressure(end/2, :, end/2)), [], 1, 1);
                    density3Dy = reshape(squeeze(solver3Dy.densitySplit(end/2, :, end/2, 2)), [], 1, 1);
                    velocity3Dy = reshape(squeeze(solver3Dy.velocity(end/2, :, end/2, 2)), [], 1, 1);

                    solver3Dz = AcousticSolver(kgrid3Dz, medium3Dz, source3Dz, [], settings); 
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

        %%

        function testAgainstLegacyAbsorption(testCase)

            % want to test Legacy code,
            % set up domains for scalar valued parameters, 1D,2D,3D
            % test grid size varied c0 and rho0 in 1D only
            % do both with and without absorption in its forms

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
            medium2Dx.absorptionType='noDispersion';
            medium2Dy.soundSpeed = c0;
            medium2Dy.density = rho0;
            medium2Dy.absorptionCoeff= alpha0;
            medium2Dy.absorptionPower= 1.9;
            medium2Dy.absorptionType='noAbsorption';
            solver2Dx = AcousticSolver(kgrid2Dx, medium2Dx, source2Dx, [], settings);
            solver2Dx.run(Nt=Nt, dt=dt);
            solver2Dy = AcousticSolver(kgrid2Dy, medium2Dy, source2Dy, [], settings);
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


    end




end

