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
% * Verifies that if the initial velocity is specified as 0 the result is
% the same as if it was not specified.

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
            pressure1D = single(solver1D.sensor.pressure);
            density1D = single(solver1D.sensor.density);

                       
            PressureActual = single((c0*rho0*initialVel(kgrid1D.xVec(floor(Nax/2)) -  c0*sensor1D.times ) - c0*rho0*initialVel(kgrid1D.xVec(floor(Nax/2)) + c0*sensor1D.times ) ))/2 ;
            testCase.verifyThat(pressure1D, IsEqualTo( PressureActual, "Within",tol))

            solver2Dx = AcousticSolver(kgrid2Dx, medium2Dx, source2Dx, sensor2Dx, settings);
            solver2Dx.run(Nt=Nt-10, dt=dt);
            solver2Dx.run(Nt=10, dt=dt);
            pressure2Dx = single(solver2Dx.sensor.pressure);
            density2Dx = single(solver2Dx.sensor.density);
            velocity2Dx = single(solver2Dx.sensor.velocity);

            testCase.verifyThat(pressure2Dx, IsEqualTo(pressure1D, "Within", tol)); %
            testCase.verifyThat(density2Dx,  IsEqualTo(density1D,  "Within", tol)); %

            solver3Dx = AcousticSolver(kgrid3Dx, medium3Dx, source3Dx, sensor3Dx, settings);
            solver3Dx.run(Nt=Nt, dt=dt);
            pressure3Dx = single(solver3Dx.sensor.pressure);
            velocity3Dx = single(solver3Dx.sensor.velocity);

            testCase.verifyThat(pressure3Dx, IsEqualTo(pressure2Dx, "Within", tol)); %
            testCase.verifyThat(velocity3Dx, IsEqualTo(velocity2Dx, "Within", tol)); %

            % Testing


            end
      end

end
