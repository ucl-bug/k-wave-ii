%% TestAcousticSensor
% *Package:* kwave.tests.unit
% *Superclasses:* matlab.unittest.AbstractTestGridInput
%
%% Description
%

classdef TestAcousticBoundaryCondition  < matlab.unittest.TestCase

    % Parameterized tests.
      methods(Test)
          function testReflection(testCase)

            import kwave.toolbox.*
            import matlab.unittest.constraints.IsEqualTo

              % Define tolerance for field comparisons.
            tol = matlab.unittest.constraints.AbsoluteTolerance(single(15e-4));
            %Accuracy of 1D on-grid reflection

            Nax = 256;
            dx = 4e-3;
            c0 = 1500;
            rho0 = 1000;
            pmlSize = 20;
            CFL = 0.5;
            %Nt = 150;
            dt = CFL * dx / c0;

            %256/2= 128. 3*128/4=96, [32,224]
            %Nt = ((225-33) )/ (CFL); 
            Nt=(((Nax+2-33-33) )/CFL);

            kgrid1D = Grid(Nax, dx, pmlSize);
            medium1D = AcousticMedium(kgrid1D);
            medium1D.soundSpeed  = c0;
            medium1D.density  = rho0;
            source1D = AcousticSource(kgrid1D);
            sensor1D= AcousticSensor(kgrid1D);
            sensor1D.mask=zeros(Nax,1);
            sensor1D.mask(floor(Nax/2))=1;
            
            source1D.initialPressure=0;
            initialPressure = @(x) exp( -( x).^2 ./ (5 * kgrid1D.dx).^2 );
            source1D.initialPressure =  initialPressure(kgrid1D.xVec);

            AcousticBoundary1D=AcousticBndryCond(kgrid1D);
            AcousticBoundary1D.mask=zeros(Nax,1);
            AcousticBoundary1D.mask([27,28,29,30,32,33,225,226,227,228,229])=1;
            AcousticBoundary1D.pressureBndry='on';

            settings = Settings;
            settings.plotSimulation = 'off';

            solver1D = AcousticSolver(kgrid1D, medium1D, source1D, [], settings);
            solver1D.applyBoundaryCondition(AcousticBoundary1D)

           solver1D.run(Nt=Nt, dt=dt);

           results = solver1D.pressure;
           expectedResults = -single(initialPressure(kgrid1D.xVec));
           testCase.verifyThat(results, IsEqualTo(expectedResults, "Within", tol)); %

            OffPoints=OffGrid(kgrid1D,[31.5,32.5,33.5,224.5,225.5,226.5]*dx-129*dx);
            Nt=(((129+129-33.5-33.5) )/CFL);
            AcousticBoundary1DOff=AcousticBndryCond(kgrid1D);
            AcousticBoundary1DOff.pressureBndry = 'on';
            AcousticBoundary1DOff.setOffGrid(OffPoints,0.00125);
            AcousticBoundary1DOff.mask=AcousticBoundary1DOff.maskBuilder;

            solver1DOG = AcousticSolver(kgrid1D, medium1D, source1D, [], settings);
            solver1DOG.applyBoundaryCondition(AcousticBoundary1DOff)

           solver1DOG.run(Nt=Nt, dt=dt);
           results = solver1DOG.pressure;
           testCase.verifyThat(results, IsEqualTo(expectedResults, "Within", tol)); %
          end

           function testReflectionOdd(testCase)

            import kwave.toolbox.*
            import matlab.unittest.constraints.IsEqualTo

              % Define tolerance for field comparisons.
            tol = matlab.unittest.constraints.AbsoluteTolerance(single(15e-4));
            %Accuracy of 1D on-grid reflection


            Nax = 257;
            dx = 4e-3;
            c0 = 1500;
            rho0 = 1000;
            pmlSize = 20;
            CFL = 0.5;
            %Nt = 150;
            dt = CFL * dx / c0;

            %256/2= 128. 3*128/4=96, [32,224]
            %Nt = ((225-33) )/ (CFL); 
            Nt=(((Nax+1-33-33) )/CFL);

            kgrid1D = Grid(Nax, dx, pmlSize);
            medium1D = AcousticMedium(kgrid1D);
            medium1D.soundSpeed  = c0;
            medium1D.density  = rho0;
            source1D = AcousticSource(kgrid1D);
            sensor1D= AcousticSensor(kgrid1D);
            sensor1D.mask=zeros(Nax,1);
            sensor1D.mask(floor(Nax/2))=1;
            
            source1D.initialPressure=0;
            initialPressure = @(x) exp( -( x).^2 ./ (5 * kgrid1D.dx).^2 );
            source1D.initialPressure =  initialPressure(kgrid1D.xVec);

            AcousticBoundary1D=AcousticBndryCond(kgrid1D);
            AcousticBoundary1D.mask=zeros(Nax,1);
            AcousticBoundary1D.mask([27,28,29,30,32,33,225,226,227,228,229])=1;
            AcousticBoundary1D.pressureBndry='on';

            settings = Settings;
            settings.plotSimulation = 'off';

            solver1D = AcousticSolver(kgrid1D, medium1D, source1D, [], settings);
            solver1D.applyBoundaryCondition(AcousticBoundary1D)

            solver1D.run(Nt=Nt, dt=dt);

            results = solver1D.pressure;
            expectedResults = -single(initialPressure(kgrid1D.xVec));
            testCase.verifyThat(results, IsEqualTo(expectedResults, "Within", tol)); %

            OffPoints=OffGrid(kgrid1D,[31.5,32.5,33.5,224.5,225.5,226.5]*dx-129*dx);
            Nt=Nt-1/CFL;
            AcousticBoundary1DOff=AcousticBndryCond(kgrid1D);
            AcousticBoundary1DOff.pressureBndry = 'on';
            AcousticBoundary1DOff.setOffGrid(OffPoints,0.00125);
            AcousticBoundary1DOff.mask=AcousticBoundary1DOff.maskBuilder;

            solver1DOG = AcousticSolver(kgrid1D, medium1D, source1D, [], settings);
            solver1DOG.applyBoundaryCondition(AcousticBoundary1DOff)

            solver1DOG.run(Nt=Nt, dt=dt);
            results = solver1DOG.pressure;
            testCase.verifyThat(results, IsEqualTo(expectedResults, "Within", tol)); %



           end

           function testSquareReflection2D(testCase)
               %%

               import kwave.toolbox.*
               import matlab.unittest.constraints.IsEqualTo

               tol = matlab.unittest.constraints.AbsoluteTolerance(single(15e-4));

               dx = 4e-3;
               c0 = 1500;
               rho0 = 1000;
               pmlSize = 20;
               Nax = 256;
               Nlat= 31;
               PointDist=100/3;
               CFL = 0.5;
               %Nt = 150;
               dt = CFL * dx / c0;

               settings = Settings;
               settings.plotSimulation = 'off';

               kgrid2D = Grid([Nax,Nlat], dx, [pmlSize,0]);
               medium2D = AcousticMedium(kgrid2D);
               medium2D.soundSpeed  = c0;
               medium2D.density  = rho0;
               source2D = AcousticSource(kgrid2D);
               source2D.initialPressure=0;
               initialPressure = @(x,y) exp( -(( x).^2 + (y.'.^2)) ./ (10* kgrid2D.dx).^2 );
               source2D.initialPressure =  initialPressure(kgrid2D.xVec,kgrid2D.yVec);
               Nt = round(((Nax-2*PointDist) )/CFL);

               source2D.initialPressure=0;
               source2D.initialPressure =  initialPressure(kgrid2D.x,0);
               line1.startPoint=[-(floor(Nax/2)-PointDist)*dx,-floor(Nlat/2)*dx];
               line1.endPoint=[-(floor(Nax/2)-PointDist)*dx,floor(Nlat/2)*dx];
               line2.startPoint=[(floor(Nax/2)-PointDist)*dx,-floor(Nlat/2)*dx];
               line2.endPoint=[(floor(Nax/2)-PointDist)*dx,floor(Nlat/2)*dx];
               line1.points=floor(Nlat);
               line2.points=floor(Nlat);
               OffPoints1=OffGrid(kgrid2D,'line',line1);
               OffPoints2=OffGrid(kgrid2D,'line',line2);
               OffPoints=OffGrid(kgrid2D,OffPoints1,OffPoints2);
               AcousticBoundary2DOff=AcousticBndryCond(kgrid2D);
               AcousticBoundary2DOff.pressureBndry = 'on';
               AcousticBoundary2DOff.setOffGrid(OffPoints,0.00125);
               AcousticBoundary2DOff.mask=AcousticBoundary2DOff.maskBuilder;
               solver2DOG = AcousticSolver(kgrid2D, medium2D, source2D, [], settings);
               solver2DOG.applyBoundaryCondition(AcousticBoundary2DOff)
               solver2DOG.run(Nt=Nt, dt=dt);
               results = solver2DOG.pressure;
               expectedResults=-single(solver2DOG.source.initialPressure);
               testCase.verifyThat(results, IsEqualTo(expectedResults, "Within", tol)); %

               kgrid2D = Grid([Nlat,Nax], dx, [0,pmlSize]);
               medium2D = AcousticMedium(kgrid2D);
               medium2D.soundSpeed  = c0;
               medium2D.density  = rho0;
               source2D = AcousticSource(kgrid2D);
               source2D.initialPressure=0;
               source2D.initialPressure =  initialPressure(kgrid2D.y,0);
               line3.startPoint=[-floor(Nlat/2)*dx,-(floor(Nax/2)-PointDist)*dx];
               line3.endPoint=[floor(Nlat/2)*dx,-(floor(Nax/2)-PointDist)*dx];
               line4.startPoint=[-floor(Nlat/2)*dx,(floor(Nax/2)-PointDist)*dx];
               line4.endPoint=[floor(Nlat/2)*dx,(floor(Nax/2)-PointDist)*dx];
               line3.points=floor(Nlat);
               line4.points=floor(Nlat);
               OffPoints3=OffGrid(kgrid2D,'line',line3);
               OffPoints4=OffGrid(kgrid2D,'line',line4);
               OffPointsNew=OffGrid(kgrid2D,OffPoints3,OffPoints4);
               AcousticBoundary2DOff2=AcousticBndryCond(kgrid2D);
               AcousticBoundary2DOff2.pressureBndry = 'on';
               AcousticBoundary2DOff2.setOffGrid(OffPointsNew,0.00125);
               AcousticBoundary2DOff2.mask=AcousticBoundary2DOff2.maskBuilder;
               solver2DOG2 = AcousticSolver(kgrid2D, medium2D, source2D, [], settings);
               solver2DOG2.applyBoundaryCondition(AcousticBoundary2DOff2)
               solver2DOG2.run(Nt=Nt, dt=dt);
               results = solver2DOG2.pressure;
               expectedResults=-single(solver2DOG2.source.initialPressure);

               testCase.verifyThat(results, IsEqualTo(expectedResults, "Within", tol)); %


               % Test will set up a 1D grid.
               % Define boundary points left and right on Dirichlet such that
               % end time = C0 * DX, DX distance between the two boundaries
               % Propagate initial condition from centre.
               % Result should be -1* initial condition

               % Test repeatable with offgrid points, different end time
               % required.

               % 2D equivalent uses a circle of radius DX.

               % 3D equivalent uses a ball of radius DX

               % Velocity Neumann implementable too, will return exact initial
               % condition needs normals implemented and execute time step.
           end


           function testSquareReflection3D(testCase)
               %%

               import kwave.toolbox.*
               import matlab.unittest.constraints.IsEqualTo

               tol = matlab.unittest.constraints.AbsoluteTolerance(single(15e-4));

               dx = 4e-3;
               c0 = 1500;
               rho0 = 1000;
               pmlSize = 20;
               Nax = 256;
               Nlat= 15;
               PointDist=100/3;
               CFL = 0.5;
               %Nt = 150;
               dt = CFL * dx / c0;

               settings = Settings;
               settings.plotSimulation = 'off';

               kgrid3D = Grid([Nlat,Nlat,Nax], dx, [0,0,pmlSize]);
               medium3D = AcousticMedium(kgrid3D);
               medium3D.soundSpeed  = c0;
               medium3D.density  = rho0;
               source3D = AcousticSource(kgrid3D);
               source3D.initialPressure=0;
               initialPressure = @(x,y,z) exp( -(( x).^2 + (y.^2) + (z.^2)) ./ (10* kgrid3D.dx).^2 );

               Nt = round(((Nax-2*PointDist) )/CFL);

               source3D.initialPressure=0;
               source3D.initialPressure =  initialPressure(0,0,kgrid3D.z);
               plane1.corner1=[-floor(Nlat/2)*dx,-floor(Nlat/2)*dx,-(floor(Nax/2)-PointDist)*dx];
               plane1.corner2=[-floor(Nlat/2)*dx,floor(Nlat/2)*dx,-(floor(Nax/2)-PointDist)*dx];
               plane1.corner3=[floor(Nlat/2)*dx,-floor(Nlat/2)*dx,-(floor(Nax/2)-PointDist)*dx];

               plane2.corner1=[-floor(Nlat/2)*dx,-floor(Nlat/2)*dx,(floor(Nax/2)-PointDist)*dx];
               plane2.corner2=[-floor(Nlat/2)*dx,floor(Nlat/2)*dx,(floor(Nax/2)-PointDist)*dx];
               plane2.corner3=[floor(Nlat/2)*dx,-floor(Nlat/2)*dx,(floor(Nax/2)-PointDist)*dx];

               plane1.points=floor(Nlat.^2);
               plane2.points=floor(Nlat.^2);
               OffPoints1=OffGrid(kgrid3D,'plane',plane1);
               OffPoints2=OffGrid(kgrid3D,'plane',plane2);
               OffPoints=OffGrid(kgrid3D,OffPoints1,OffPoints2);
               AcousticBoundary3DOff=AcousticBndryCond(kgrid3D);
               AcousticBoundary3DOff.pressureBndry = 'on';
               AcousticBoundary3DOff.setOffGrid(O+ ...
                   ffPoints,0.00125);
               AcousticBoundary3DOff.mask=AcousticBoundary3DOff.maskBuilder;
               solver3DOG = AcousticSolver(kgrid3D, medium3D, source3D, [], settings);
               solver3DOG.applyBoundaryCondition(AcousticBoundary3DOff)
               solver3DOG.run(Nt=Nt, dt=dt);
               results = solver3DOG.pressure;
               expectedResults=-single(solver3DOG.source.initialPressure);
               testCase.verifyThat(results, IsEqualTo(expectedResults, "Within", tol)); %
               % Due to length of time only the third dimension is tested

           end

           % function testCircle2D(testCase)
           %      import kwave.toolbox.*
           %      % Test case idea is to observe that the reflection is in
           %      % all directions including off axis. 
           %      % Idea was to propagate a bell from the centre to the edges
           %      % and back.
           %      % TODO: Implement initial pressure and velocity such that
           %      % the refletion is correctly observed. Consider wave modes.
           % 
           %      Nax = 256;
           %      WallDist=200/3;
           % 
           %      dx = 4e-3;
           %      c0 = 1500;
           %      rho0 = 1000;
           %      pmlSize = 20;
           %      CFL = 0.5;
           %      dt = CFL * dx / c0;
           %      settings = Settings;
           %      settings.plotSimulation = 'on';
           % 
           %      kgrid2D = Grid([Nax,Nax], dx, [pmlSize,pmlSize]);
           %      medium2D = AcousticMedium(kgrid2D);
           %      medium2D.soundSpeed  = c0;
           %      medium2D.density  = rho0;
           % 
           %      initialPressure  = @(x,y) % % Needed
           %      initialVelocityX = @(x,y) % % Needed
           %      initialVelocityY = @(x,y) % % Needed
           % 
           %      radius=(Nax/2-WallDist)*dx;
           %      Nt = 2*round((Nax/2-WallDist )/CFL);
           % 
           % 
           %      source2D = AcousticSource(kgrid2D);
           %      source2D.initialPressure=0;
           %      source2D.initialVelocity=zeros([Nax,Nax,1,2]);
           %      source2D.initialPressure =  initialPressure(kgrid2D.x,kgrid2D.y);
           %      source2D.initialVelocity(:,:,1) =  initialVelocityX(kgrid2D.x,kgrid2D.y);
           %      source2D.initialVelocity(:,:,2) =  initialVelocityY(kgrid2D.x,kgrid2D.y);
           % 
           %      circle.radius=radius;
           %      circle.centre=[0,0];
           %      circle.points=floor(2*radius/dx*pi);
           %      OffCircle=OffGrid(kgrid2D,'circle',circle);
           %      AcousticBoundary2D=AcousticBndryCond(kgrid2D);
           %      AcousticBoundary2D.setOffGrid(OffCircle,0.00125);
           %      AcousticBoundary2D.mask=AcousticBoundary2D.maskBuilder;
           %      AcousticBoundary2D.pressureBndry='on';
           %      solver2D = AcousticSolver(kgrid2D, medium2D, source2D, [], settings);
           %      solver2D.applyBoundaryCondition(AcousticBoundary2D)
           %      offCentre=60;
           %      r0=source2D.initialPressure;
           %      solver2D.run(Nt=Nt/2-offCentre, dt=dt);
           %      r1=solver2D.pressure;
           %      solver2D.run(Nt=2*offCentre, dt=dt);
           %      r2=solver2D.pressure;
           %      solver2D.run(Nt=Nt/2-offCentre, dt=dt);
           %      r3=solver2D.pressure;
           % 
           % end



      end

end
