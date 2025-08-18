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

            Nax = 256;
            dx = 4e-3;
            c0 = 1500;
            rho0 = 1000;
            pmlSize = 20;
            CFL = 0.5;
            %Nt = 150;
            dt = CFL * dx / c0;

            % 256/2= 128. 3*128/4=96, [32,224]
            %((224-32)*dx / c0 )/dt; 
            Nt=384;

            kgrid1D = Grid(Nax, dx, pmlSize);
            medium1D = AcousticMedium(kgrid1D);
            source1D = AcousticSource(kgrid1D);
            sensor1D= AcousticSensor(kgrid1D);
            sensor1D.mask=zeros(Nax,1);
            sensor1D.mask(floor(Nax/2))=1;
            
            source1D.initialPressure=0;
            initialVel = @(x) (1/(rho0*c0)) * exp( -( x).^2 ./ (5 * kgrid1D.dx).^2 );
            source1D.initialVelocity =  initialVel(kgrid1D.xVec);

            AcousticBoundary1D=AcousticBoundaryCondition(kgrid1D);
            AcousticBoundary1D.mask=zeros(256,1);
            AcousticBoundary1D.mask([32,224])=1;
            AcousticBoundary1D.pressureBndry='on';
            solver1D = AcousticSolver(kgrid1D, medium1D, source1D, sensor1D, settings);
            solver1D.boundaryCondition(AcousticBoundary1D)

            solver1D.run(Nt=Nt, dt=dt);

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
