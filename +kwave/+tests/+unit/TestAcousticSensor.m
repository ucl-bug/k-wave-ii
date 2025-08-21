%% TestAcousticSensor
% *Package:* kwave.tests.unit
% *Superclasses:* matlab.unittest.AbstractTestGridInput
%
%% Description
%

classdef TestAcousticSensor  < matlab.unittest.TestCase

    % Parameterized tests.
      methods(Test)
            function testVelcityPlaneWaves(testCase)

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

            % Construct Mediums

            kgrid1D = Grid(Nax, dx, pmlSize);
            medium1D = AcousticMedium(kgrid1D);
            source1D = AcousticSource(kgrid1D);
            sensor1D= AcousticSensor(kgrid1D);
            sensor1D.mask=zeros(Nax,1);
            sensor1D.mask(floor(Nax/2))=1;
            sensor1D.pressureSensor='on';
            sensor1D.densitySensor='on';
            sensor1D.velocitySensor='on';
            

            source1D.initialPressure=0;
            initialVel = @(x) (1/(rho0*c0)) * exp( -( x - 25e-3).^2 ./ (5 * kgrid1D.dx).^2 );
            source1D.initialVelocity =  initialVel(kgrid1D.xVec);

            kgrid2Dx = Grid([Nax, Nlat], dx, [pmlSize, 0]);
            medium2Dx = AcousticMedium(kgrid2Dx);
            source2Dx = AcousticSource(kgrid2Dx);
            source2Dx.initialVelocity = zeros([Nax,Nlat,1,2]);
            source2Dx.initialPressure=0;
            source2Dx.initialVelocity(:,:,:,1) = repmat(source1D.initialVelocity, [1, Nlat]);
            sensor2Dx= AcousticSensor(kgrid2Dx);
            sensor2Dx.mask=zeros(Nax,Nlat);
            sensor2Dx.mask(floor(Nax/2),floor(Nlat/2))=1;
            sensor2Dx.pressureSensor='on';
            sensor2Dx.densitySensor='on';
            sensor2Dx.velocitySensor='ongrid';

            kgrid3Dx = Grid([Nax, Nlat, Nlat], dx, [pmlSize, 0, 0]);
            medium3Dx = AcousticMedium(kgrid3Dx);
            source3Dx = AcousticSource(kgrid3Dx);
            source3Dx.initialVelocity = zeros([Nax,Nlat,Nlat,3]);
            source3Dx.initialPressure=0;
            source3Dx.initialVelocity(:,:,:,1) = repmat(source1D.initialVelocity, [1, Nlat, Nlat]);
            sensor3Dx= AcousticSensor(kgrid3Dx);
            sensor3Dx.mask=zeros(Nax,Nlat,Nlat);
            sensor3Dx.mask(floor(Nax/2),floor(Nlat/2),floor(Nlat/2))=1;
            sensor3Dx.pressureSensor='on';
            sensor3Dx.densitySensor='on';
            sensor3Dx.velocitySensor='ongrid';

            medium1D.soundSpeed  = c0;
            medium1D.density  = rho0;
            medium2Dx.soundSpeed = c0;
            medium2Dx.density = rho0;
            medium3Dx.soundSpeed = c0;
            medium3Dx.density = rho0;

            %Reference Solution
            solver1D = AcousticSolver(kgrid1D, medium1D, source1D, sensor1D, settings);
            solver1D.run(Nt=Nt, dt=dt);
                       
            PressureActual = single((c0*rho0*initialVel(kgrid1D.xVec(floor(Nax/2)) -  c0*sensor1D.times ) - c0*rho0*initialVel(kgrid1D.xVec(floor(Nax/2)) + c0*sensor1D.times ) ))/2 ;
            VelocityActual = single((initialVel(kgrid1D.xVec(floor(Nax/2)) -  c0*sensor1D.times +dt/2 ) + initialVel(kgrid1D.xVec(floor(Nax/2)) + c0*sensor1D.times +dt/2 ) ))/2 ;
            testCase.verifyThat(solver1D.sensor.pressure, IsEqualTo( PressureActual, "Within",tol))

            solver2Dx = AcousticSolver(kgrid2Dx, medium2Dx, source2Dx, sensor2Dx, settings);
            solver2Dx.run(Nt=Nt-10, dt=dt);
            solver2Dx.run(Nt=10, dt=dt);

            testCase.verifyThat(solver2Dx.sensor.pressure, IsEqualTo(solver1D.sensor.pressure, "Within", tol)); %
            testCase.verifyThat(solver2Dx.sensor.density,  IsEqualTo(solver1D.sensor.density,  "Within", tol)); %

            solver3Dx = AcousticSolver(kgrid3Dx, medium3Dx, source3Dx, sensor3Dx, settings);
            solver3Dx.run(Nt=Nt, dt=dt);

            testCase.verifyThat(solver3Dx.sensor.pressure, IsEqualTo(solver2Dx.sensor.pressure, "Within", tol)); %
            testCase.verifyThat(solver3Dx.sensor.velocity(:,1,:), IsEqualTo(solver2Dx.sensor.velocity(:,1,:), "Within", tol)); %
            testCase.verifyThat(reshape(solver3Dx.sensor.velocity(:,1,:),[1,151]), IsEqualTo(VelocityActual, "Within", tol)); %

            % Testing


            end


            function testVelcityPlaneWavesOffGrid(testCase)

            import kwave.toolbox.*
            import matlab.unittest.constraints.IsEqualTo
            
            Tol=3e-6;
            % Define tolerance for field comparisons.
            tol = matlab.unittest.constraints.AbsoluteTolerance(single(Tol));

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

            % Construct Mediums

            kgrid1D = Grid(Nax, dx, pmlSize);
            medium1D = AcousticMedium(kgrid1D);
            source1D = AcousticSource(kgrid1D);
            sensor1D= AcousticSensor(kgrid1D);

            
            OffGrid1D=OffGrid(kgrid1D,[-dx/3,0,dx/3]);
            sensor1D.setOffGrid(OffGrid1D,Tol);
            sensor1D.mask=sensor1D.maskBuilder;
            sensor1D.pressureSensor='on';
            sensor1D.densitySensor='on';
            sensor1D.velocitySensor='on';
            

            source1D.initialPressure=0;
            initialVel = @(x) (1/(rho0*c0)) * exp( -( x - 25e-3).^2 ./ (5 * kgrid1D.dx).^2 );
            source1D.initialVelocity =  initialVel(kgrid1D.xVec);

            kgrid2Dx = Grid([Nax, Nlat], dx, [pmlSize, 0]);
            medium2Dx = AcousticMedium(kgrid2Dx);
            source2Dx = AcousticSource(kgrid2Dx);
            source2Dx.initialVelocity = zeros([Nax,Nlat,1,2]);
            source2Dx.initialPressure=0;
            source2Dx.initialVelocity(:,:,:,1) = repmat(source1D.initialVelocity, [1, Nlat]);

            
            sensor2Dx= AcousticSensor(kgrid2Dx);
            OffGrid2D=OffGrid(kgrid2Dx,[-dx/3 -dx/2; 0 0; dx/3 dx/2]);
            sensor2Dx.setOffGrid(OffGrid2D,Tol);
            sensor2Dx.mask=sensor2Dx.maskBuilder;
            sensor2Dx.pressureSensor='on';
            sensor2Dx.densitySensor='on';
            sensor2Dx.velocitySensor='ongrid';

            kgrid3Dx = Grid([Nax, Nlat, Nlat], dx, [pmlSize, 0, 0]);
            medium3Dx = AcousticMedium(kgrid3Dx);
            source3Dx = AcousticSource(kgrid3Dx);
            source3Dx.initialVelocity = zeros([Nax,Nlat,Nlat,3]);
            source3Dx.initialPressure=0;
            source3Dx.initialVelocity(:,:,:,1) = repmat(source1D.initialVelocity, [1, Nlat, Nlat]);

            
            sensor3Dx= AcousticSensor(kgrid3Dx);

            OffGrid3D=OffGrid(kgrid3Dx,[-dx/3 -dx/2 dx/4; 0 0 dx/4; dx/3 dx/2 dx/4 ; dx/2 0 0]);
            sensor3Dx.setOffGrid(OffGrid3D,Tol);
            sensor3Dx.mask=sensor3Dx.maskBuilder;

            sensor3Dx.pressureSensor='on';
            sensor3Dx.densitySensor='on';
            sensor3Dx.velocitySensor='ongrid';

            medium1D.soundSpeed  = c0;
            medium1D.density  = rho0;
            medium2Dx.soundSpeed = c0;
            medium2Dx.density = rho0;
            medium3Dx.soundSpeed = c0;
            medium3Dx.density = rho0;

            %Reference Solution
            solver1D = AcousticSolver(kgrid1D, medium1D, source1D, sensor1D, settings);
            solver1D.run(Nt=Nt, dt=dt);
                       
            PressureActual = single((c0*rho0*initialVel(-dx/3 -  c0*sensor1D.times ) - c0*rho0*initialVel(-dx/3 + c0*sensor1D.times ) ))/2 ;

            VelocityActual = single((initialVel(-dx/2 -  c0*sensor1D.times +dt/2 ) + initialVel(-dx/2 + c0*sensor1D.times +dt/2 ) ))/2 ;
            
            testCase.verifyThat(solver1D.sensor.pressure(1,:), IsEqualTo( PressureActual, "Within",tol))

            solver2Dx = AcousticSolver(kgrid2Dx, medium2Dx, source2Dx, sensor2Dx, settings);
            solver2Dx.run(Nt=Nt-10, dt=dt);
            solver2Dx.run(Nt=10, dt=dt);

            testCase.verifyThat(solver2Dx.sensor.pressure(2,:), IsEqualTo(solver1D.sensor.pressure(2,:), "Within", tol)); %
            testCase.verifyThat(solver2Dx.sensor.density(1,:),  IsEqualTo(solver1D.sensor.density(1,:),  "Within", tol)); %

            solver3Dx = AcousticSolver(kgrid3Dx, medium3Dx, source3Dx, sensor3Dx, settings);
            solver3Dx.run(Nt=Nt, dt=dt);

            testCase.verifyThat(solver3Dx.sensor.pressure(3,:), IsEqualTo(solver2Dx.sensor.pressure(3,:), "Within", tol)); %
            testCase.verifyThat(solver3Dx.sensor.velocity(1,1,:), IsEqualTo(solver2Dx.sensor.velocity(1,1,:), "Within", tol)); %
            testCase.verifyThat(reshape(solver3Dx.sensor.velocity(2,1,:),[1,151]), IsEqualTo(VelocityActual, "Within", tol)); %
            % Testing
            end

      function testVelcityPlaneWavesStaggerOff(testCase)

            import kwave.toolbox.*
            import matlab.unittest.constraints.IsEqualTo
            
            Tol=3e-6;
            % Define tolerance for field comparisons.
            tol = matlab.unittest.constraints.AbsoluteTolerance(single(Tol));

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
            settings.spatialStaggering='off';

            % Construct Mediums

            kgrid1D = Grid(Nax, dx, pmlSize);
            medium1D = AcousticMedium(kgrid1D);
            source1D = AcousticSource(kgrid1D);
            sensor1D= AcousticSensor(kgrid1D);

            
            OffGrid1D=OffGrid(kgrid1D,[-dx/3,0,dx/3]);
            sensor1D.setOffGrid(OffGrid1D,Tol);
            sensor1D.mask=sensor1D.maskBuilder;
            sensor1D.pressureSensor='on';
            sensor1D.densitySensor='on';
            sensor1D.velocitySensor='on';
            

            source1D.initialPressure=0;
            initialVel = @(x) (1/(rho0*c0)) * exp( -( x - 25e-3).^2 ./ (5 * kgrid1D.dx).^2 );
            source1D.initialVelocity =  initialVel(kgrid1D.xVec);

            kgrid2Dx = Grid([Nax, Nlat], dx, [pmlSize, 0]);
            medium2Dx = AcousticMedium(kgrid2Dx);
            source2Dx = AcousticSource(kgrid2Dx);
            source2Dx.initialVelocity = zeros([Nax,Nlat,1,2]);
            source2Dx.initialPressure=0;
            source2Dx.initialVelocity(:,:,:,1) = repmat(source1D.initialVelocity, [1, Nlat]);

            
            sensor2Dx= AcousticSensor(kgrid2Dx);
            OffGrid2D=OffGrid(kgrid2Dx,[-dx/3 -dx/2; 0 0; dx/3 dx/2]);
            sensor2Dx.setOffGrid(OffGrid2D,Tol);
            sensor2Dx.mask=sensor2Dx.maskBuilder;
            sensor2Dx.pressureSensor='on';
            sensor2Dx.densitySensor='on';
            sensor2Dx.velocitySensor='ongrid';

            kgrid3Dx = Grid([Nax, Nlat, Nlat], dx, [pmlSize, 0, 0]);
            medium3Dx = AcousticMedium(kgrid3Dx);
            source3Dx = AcousticSource(kgrid3Dx);
            source3Dx.initialVelocity = zeros([Nax,Nlat,Nlat,3]);
            source3Dx.initialPressure=0;
            source3Dx.initialVelocity(:,:,:,1) = repmat(source1D.initialVelocity, [1, Nlat, Nlat]);

            
            sensor3Dx= AcousticSensor(kgrid3Dx);

            OffGrid3D=OffGrid(kgrid3Dx,[-dx/3 -dx/2 dx/4; 0 0 dx/4; dx/3 dx/2 dx/4 ; dx/2 0 0]);
            sensor3Dx.setOffGrid(OffGrid3D,Tol);
            sensor3Dx.mask=sensor3Dx.maskBuilder;

            sensor3Dx.pressureSensor='on';
            sensor3Dx.densitySensor='on';
            sensor3Dx.velocitySensor='ongrid';

            medium1D.soundSpeed  = c0;
            medium1D.density  = rho0;
            medium2Dx.soundSpeed = c0;
            medium2Dx.density = rho0;
            medium3Dx.soundSpeed = c0;
            medium3Dx.density = rho0;

            %Reference Solution
            solver1D = AcousticSolver(kgrid1D, medium1D, source1D, sensor1D, settings);
            solver1D.run(Nt=Nt, dt=dt);
                       
            PressureActual = single((c0*rho0*initialVel(-dx/3 -  c0*sensor1D.times ) - c0*rho0*initialVel(-dx/3 + c0*sensor1D.times ) ))/2 ;

            VelocityActual = single((initialVel(-dx/2 -  c0*sensor1D.times +dt/2 ) + initialVel(-dx/2 + c0*sensor1D.times +dt/2 ) ))/2 ;
            
            testCase.verifyThat(solver1D.sensor.pressure(1,:), IsEqualTo( PressureActual, "Within",tol))

            solver2Dx = AcousticSolver(kgrid2Dx, medium2Dx, source2Dx, sensor2Dx, settings);
            solver2Dx.run(Nt=Nt-10, dt=dt);
            solver2Dx.run(Nt=10, dt=dt);

            testCase.verifyThat(solver2Dx.sensor.pressure(2,:), IsEqualTo(solver1D.sensor.pressure(2,:), "Within", tol)); %
            testCase.verifyThat(solver2Dx.sensor.density(1,:),  IsEqualTo(solver1D.sensor.density(1,:),  "Within", tol)); %

            solver3Dx = AcousticSolver(kgrid3Dx, medium3Dx, source3Dx, sensor3Dx, settings);
            solver3Dx.run(Nt=Nt, dt=dt);

            testCase.verifyThat(solver3Dx.sensor.pressure(3,:), IsEqualTo(solver2Dx.sensor.pressure(3,:), "Within", tol)); %
            testCase.verifyThat(solver3Dx.sensor.velocity(1,1,:), IsEqualTo(solver2Dx.sensor.velocity(1,1,:), "Within", tol)); %
            testCase.verifyThat(reshape(solver3Dx.sensor.velocity(2,1,:),[1,151]), IsEqualTo(VelocityActual, "Within", tol)); %
            % Testing
            end
      end

end
