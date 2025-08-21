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
            settings.plotSimulation = 'on';

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

            % kgrid2D = Grid([Nax,Nax], dx, pmlSize);
            % medium2D = AcousticMedium(kgrid2D);
            % medium2D.soundSpeed  = c0;
            % medium2D.density  = rho0;
            % source2D = AcousticSource(kgrid2D);
            % source2D.initialPressure=0;
            % initialPressure = @(x,y) exp( -(( x).^2 + (y.'.^2)) ./ (10* kgrid2D.dx).^2 );
            % source2D.initialPressure =  initialPressure(kgrid2D.xVec,kgrid2D.yVec);
            % Nt = 2*round(((Nax-132-132) )/CFL);
            % 
            % radius=(Nax/2-132)*dx;
            % AcousticBoundary2D=AcousticBndryCond(kgrid2D);
            % AcousticBoundary2D.mask=zeros(Nax,Nax);
            % AcousticBoundary2D.mask((kgrid2D.x.^2 + kgrid2D.y.^2)>=(radius-dx/2).^2)=1;
            % AcousticBoundary2D.mask((kgrid2D.x.^2 + kgrid2D.y.^2)>=(radius+dx/2).^2)=0;
            % AcousticBoundary2D.pressureBndry='on';
            % solver2D = AcousticSolver(kgrid2D, medium2D, source2D, [], settings);
            % solver2D.applyBoundaryCondition(AcousticBoundary2D)
            % solver2D.run(Nt=Nt, dt=dt);
            % expectedResults = -solver2D.pressure(round(Nax)/2-50:round(Nax)/2+49,round(Nax)/2-50:round(Nax)/2+49);
            % solver2D.run(Nt=Nt, dt=dt);
            % results = solver2D.pressure(round(Nax)/2-50:round(Nax)/2+49,round(Nax)/2-50:round(Nax)/2+49);

            
            % 
            % source2D.initialPressure=0;
            % initialPressure = @(x,y) exp( -( x).^2 ./ (10 * kgrid2D.dx).^2 );
            % source2D.initialPressure =  initialPressure(kgrid2D.x,kgrid2D.yVec);
            % line1.startPoint=[-(129-33.5)*dx,-128*dx];
            % line1.endPoint=[-(129-33.5)*dx,128*dx];
            % line2.startPoint=[(129-33.5)*dx,-128*dx];
            % line2.endPoint=[(129-33.5)*dx,128*dx];
            % line1.points=258;
            % line2.points=258;
            % OffPoints1=OffGrid(kgrid2D,'line',line1);
            % OffPoints2=OffGrid(kgrid2D,'line',line2);
            % OffPoints=OffGrid(kgrid2D,OffPoints1,OffPoints2);
            % AcousticBoundary2DOff=AcousticBndryCond(kgrid2D);
            % AcousticBoundary2DOff.pressureBndry = 'on';
            % AcousticBoundary2DOff.setOffGrid(OffPoints2,0.00125);
            % AcousticBoundary2DOff.mask=AcousticBoundary2DOff.maskBuilder;
            % solver2DOG = AcousticSolver(kgrid2D, medium2D, source2D, [], settings);
            % solver2DOG.applyBoundaryCondition(AcousticBoundary2DOff)
            % solver2DOG.run(Nt=Nt, dt=dt);

            % source2D.initialPressure=0;
            % initialPressure = @(x,y) exp( -(( x).^2 + (y.'.^2)) ./ (5 * kgrid2D.dx).^2 );
            % initialVelocity1 = @(x,y) 1/(c0^2*rho0) * x .* exp( -(( x).^2 + (y.'.^2)) ./ (5 * kgrid2D.dx).^2 );
            % initialVelocity2 = @(x,y) 1/(c0^2*rho0) * y.' .* exp( -(( x).^2 + (y.'.^2)) ./ (5 * kgrid2D.dx).^2 );
            % source2D.initialPressure =  initialPressure(kgrid2D.xVec,kgrid2D.yVec);
            % source2D.initialVelocity=zeros(Nax,Nax,1,2);
            % source2D.initialVelocity(:,:,:,1) =  initialVelocity1(kgrid2D.xVec,kgrid2D.yVec);
            % source2D.initialVelocity(:,:,:,2) =  initialVelocity2(kgrid2D.xVec,kgrid2D.yVec);
            % 

            % circ.radius=(Nax-132)*dx;
            % circ.centre=[0,0];
            % circ.points= floor(2*pi*circ.radius/dx)+2;
            % OffPoints=OffGrid(kgrid2D,'circle',circ);
            % AcousticBoundary2DOff=AcousticBndryCond(kgrid2D);
            % AcousticBoundary2DOff.pressureBndry = 'on';
            % AcousticBoundary2DOff.setOffGrid(OffPoints,0.000625);
            % AcousticBoundary2DOff.mask=AcousticBoundary2DOff.maskBuilder;
            % solver2DOG = AcousticSolver(kgrid2D, medium2D, source2D, [], settings);
            % solver2DOG.applyBoundaryCondition(AcousticBoundary2DOff)
            % solver2DOG.run(Nt=Nt, dt=dt);
            % expectedResults = -solver2DOG.pressure(round(Nax)/2-50:round(Nax)/2+49,round(Nax)/2-50:round(Nax)/2+49);
            % solver2DOG.run(Nt=Nt, dt=dt);
            % results = solver2DOG.pressure(round(Nax)/2-50:round(Nax)/2+49,round(Nax)/2-50:round(Nax)/2+49);
           
            % results = solver2DOG.pressure(100:158,100:158);
            % %expectedResults = single(initialPressure(kgrid2D.xVec,kgrid2D.yVec));
            % testCase.verifyThat(results, IsEqualTo(expectedResults, "Within", tol)); %


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
      end

end
