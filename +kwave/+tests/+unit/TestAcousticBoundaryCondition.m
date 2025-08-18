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
            dx = 2e-3;
            c0 = 1500;
            rho0 = 1000;
            pmlSize = 20;
            CFL = 0.5;
            %Nt = 150;
            dt = CFL * dx / c0;

            % 256/2= 128. 3*128/4=96, [32,224]
            % Nt = ((225-33) )/ (CFL); 
            Nt=384;

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
            AcousticBoundary1D.mask=zeros(256,1);
            AcousticBoundary1D.mask([29,30,31,32,33,225,226,227,228,229])=1;
            AcousticBoundary1D.pressureBndry='on';

            settings = Settings;
            settings.plotSimulation = 'on';

            solver1D = AcousticSolver(kgrid1D, medium1D, source1D, [], settings);
            solver1D.applyBoundaryCondition(AcousticBoundary1D)

            %solver1D.run(Nt=Nt, dt=dt);

            %results = solver1D.pressure;
            expectedResults = -single(initialPressure(kgrid1D.xVec));
            %testCase.verifyThat(results, IsEqualTo(expectedResults, "Within", tol)); %

            OffPoints=OffGrid(kgrid1D,[31.5,32.5,33.5,224.5,225.5,226.5]*dx-129*dx);
            Nt=382;
            AcousticBoundary1DOff=AcousticBndryCond(kgrid1D);
            AcousticBoundary1DOff.pressureBndry = 'on';
            AcousticBoundary1DOff.setOffGrid(OffPoints,0.001);
            AcousticBoundary1DOff.mask=AcousticBoundary1DOff.maskBuilder;

            solver1DOG = AcousticSolver(kgrid1D, medium1D, source1D, [], settings);
            solver1DOG.applyBoundaryCondition(AcousticBoundary1DOff)

            solver1DOG.run(Nt=Nt, dt=dt);
            results = solver1DOG.pressure;
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
      end

end
