%% TestAcousticSensor
% *Package:* kwave.tests.unit
% *Superclasses:* matlab.unittest.AbstractTestGridInput
%
%% Description
%

classdef TestOffGrid  < matlab.unittest.TestCase

    % Parameterized tests.
    methods(Test)
        function testOffGridConstruction(testCase)

            % Things to test:
            % fails to build on a 1D grid if 2D or 3D points
            % equiv to 2D and 3D
            % passes on 1D-1D,2D-2D, 3D-3D
            % Fails if grid point is outside of domain

            import kwave.toolbox.*
            import matlab.unittest.constraints.IsEqualTo


        end


        function runPreBuilds(testCase)

            % Test each of the prebuilds run in turn.
            import kwave.toolbox.*
            import matlab.unittest.constraints.IsEqualTo

            tol = matlab.unittest.constraints.AbsoluteTolerance(single(1e-6));

            % Test properties.
            Nax = 256;
            Nlat = 16;
            dx = 4e-3;
            pmlSize = 20;

            % Settings.
            settings = Settings;
            settings.plotSimulation = 'off';

            % Construct Mediums

            kgrid1D = Grid(Nax, dx, pmlSize);
            OffGrid1D=OffGrid(kgrid1D,[-dx/3,0,dx/3]);

            kgrid2Dx = Grid([Nax, Nlat], dx, [pmlSize, 0]);
            OffGrid2D=OffGrid(kgrid2Dx,[-dx/3 -dx/2; 0 0; dx/3 dx/2]);

            line.points=10;
            line.endPoint=[-3*dx,-dx];
            line.startPoint=[3*dx,+5*dx];
            OffGrid2DLine=OffGrid(kgrid2Dx,'line',line);

            circle.centre=[0,0];
            circle.radius = 5*dx;
            circle.points=40;
            OffGrid2DCircle=OffGrid(kgrid2Dx,'circle',circle);

            arc.centre=[0,0];
            arc.radius=5*dx;
            arc.points=40;
            arc.startAngle=pi/4;
            arc.endAngle=3*pi/4;
            OffGrid2DArc=OffGrid(kgrid2Dx,'arc',arc);

            arc2.radius=5*dx;
            arc2.points=40;
            arc2.diameter=2*dx;
            arc2.midpoint=[0,-5*dx];
            arc2.focusPosition=[0,-2*dx];
            OffGrid2DArc2=OffGrid(kgrid2Dx,'arc',arc2);

            disk.radius=5*dx;
            disk.points=75;
            disk.centre=[0,0];
            OffGrid2DDisk=OffGrid(kgrid2Dx,'filledCircle',disk);

            OffGrid2Dadded=OffGrid(kgrid2Dx,OffGrid2DLine,OffGrid2DArc);

            kgrid3Dx = Grid([Nax, Nlat, Nlat], dx, [pmlSize, 0, 0]);
            OffGrid3D=OffGrid(kgrid3Dx,[-dx/3 -dx/2 dx/4; 0 0 dx/4; dx/3 dx/2 dx/4 ; dx/2 0 0]);

            ball.centre=[0,0,0];
            ball.radius=5*dx;
            ball.pointsTheta=10;
            ball.pointsPhi=20;
            OffGrid3DBall=OffGrid(kgrid3Dx,'ball',ball);
            
            disk.centre=[0,0,dx];
            disk.focusPoint=[0,dx,dx/2];
            OffGrid3DDisk=OffGrid(kgrid3Dx,'disk',disk);



          end
      end

end
