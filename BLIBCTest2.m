clear
close all
import kwave.toolbox.*

dx=1e-3;
for m=7:7
    for eo=0:0
        figure(2*m+eo)
        tiledlayout(1,5)
        vec= ceil(3*2^(m-4)*pi)+[-5:-1];
        for points=1:5
        
            

        kgrid2D = Grid([2^m+eo, 2^m+eo], dx ,20);

        circ.centre=[0,0];
        circ.radius= 3*2^(m-4)*dx;
        % CircleOG=OffGrid(kgrid2D,ceil(3*2^(m-3)*pi),'circle',circ);
         CircleOG=OffGrid(kgrid2D,vec(points),'circle',circ);

        medium2D=Medium(kgrid2D);
        medium2D.materialIDGrid=1;
        source = AcousticSource(kgrid2D);
        setting=Settings;
        setting.plotSimulation='off';

        source.initialPressure = exp( -(kgrid2D.x.^2+kgrid2D.y.^2) ./ (5 * kgrid2D.dx).^2 );

        solver=AcousticSolver(kgrid2D, medium2D, source, [],setting);
        CircleBC=OffGridBoundaryCondition(kgrid2D,CircleOG,accuracy=0.001);
        CircleBC.mask=CircleBC.maskBuilder;
        solver.setPressureBoundaryCondition(CircleBC)

        solver.run(Nt=5*2^m,dt=1e-7) %Off Grid boundary in circle, velocity boundary condition
        
        figure(2*m+eo)
        nexttile(points)

        error=abs(solver.pressure+source.initialPressure);
        error( (kgrid2D.x.^2+kgrid2D.y.^2) > circ.radius.^2)=0;
        contourf(kgrid2D.xVec,kgrid2D.yVec,error);
        title(num2str(floor(3*2^points*pi)))
        colorbar
        drawnow
        % radius= 3 2^m-3 dx, to wall and back = 3 2^m-2 dx /1500 time.
        % 1500= 3/2 x10^3, time there and back 2^m-1 x10^-6, time step 10-7,
        % Time steps  5 * 2^m
        end
    end
end

