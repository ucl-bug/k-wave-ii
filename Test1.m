% Test 1

% Velocity 0 boundary reflection

% 1D Domain, Boundary On-Grid.

clear
close all
import kwave.toolbox.*
% for num=1:10
    for num=1:1
    figure(num+1)
    hold off
    decision='on';
    for Nx=190:16:378
      % for Nx=190:16:190
        % Nx=132;
        dx=(1e-3)*190/Nx;
        kgrid1D = Grid(Nx, dx,20);
        v1= -(ceil(Nx/4)+1/3)*dx;
        v2= -(ceil(Nx/4)+1+1/3)*dx;
        % v2= -(ceil(Nx/4)+1/num+1/3)*dx;
        % v2= -(ceil(Nx/4)+1+(num-1)/5+1/3)*dx;
        % OG=OffGrid(kgrid1D,num+1,[v2:dx/(num):v1]);
        OG=OffGrid(kgrid1D,2,[v2,v1]);
        medium1D=Medium(kgrid1D);
        medium1D.materialIDGrid=1;
        source = AcousticSource(kgrid1D);
        setting=Settings;
        setting.plotSimulation=decision;
        sensor=AcousticSensor(kgrid1D);
        sensor.mask=zeros(Nx,1);
        sensor.mask(ceil(Nx/4)+1:floor(3*Nx/4))=1;
        source.initialPressure = zeros(Nx,1);
        source.initialPressure(ceil(3*Nx/4):Nx) = -(cos( 2*pi*(((ceil(3*Nx/4):Nx)-ceil(6*Nx/8))/(Nx-ceil(3*Nx/4))))-1);
        solver=AcousticSolver(kgrid1D, medium1D, source, sensor,setting);

        BC1=OffGridBoundaryCondition(kgrid1D,OG,accuracy=0.0075);
        BC1.mask=BC1.maskBuilder;

        BC2=OffGridBoundaryCondition(kgrid1D,OG,accuracy=0.0075,staggering='forward');
        BC2.mask=BC2.maskBuilder;
        solver.setPressureBoundaryCondition(BC1)
        % solver.setVelocityBoundaryCondition(BC2)

        solver.run(Nt=800,dt=2.5e-7)
        figure(num+1)
        plot(solver.timeArray,solver.sensor.pressure(5,:))
        hold on
        plot(solver.timeArray,solver.sensor.pressure(end,:),'--')

        figure(num+2)
       % plot(solver.timeArray,solver.sensor.pressure(5,:))
        plot(solver.timeArray,solver.sensor.pressure(end,:),'--')
        hold on

        decision='off';
    end
end
% Test 1 Largely fails. Increasing the number of grid points in general
% decreases the accuracy for only 1 or 2 boundary points, even if they are
% 'together'  it may be improved by increasing the number of points on the
% other side, adding more forcing, but the most basic case does fail. This
% has not been compared to the hard boundary on grid  version. i.e. 1 point
% stencil

% Test 1 Edit 1. Introducing a thickness to the boundary condition such
% that the boundary points are grid point distance apart causes the
% boundary to work significantly better, even with only 3 grid points. The
% question becomes however, where exactly is the boundary?

% Test 2 Potential. Fix Boundary width but vary how many boundary points
% there are to check for if stability may depend on this.
% Fix number of boundary points, or their distance apart, and vary the
% distance between them.
