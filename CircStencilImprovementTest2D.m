%%

clear
close all
import kwave.toolbox.*

radius=0.045;
acc=[0.1,0.05,0.025,0.01,0.005,0.0025,0.001];
mVal=[5,8,14,33,65,129,320];

circ.radius=radius;
circ.centre=[0,0];

dxval=[1e-2,5e-3,1e-3,5e-4,1e-4]%,5e-5,1e-5];
for j2=3:3 %7

dx=dxval(j2)
% dx=1e-3;

pointcount=floor(2.5*radius*pi/dx);

kgrid2D=Grid([ 2*(radius/dx)+3, 2*(radius/dx)+3 ],  dx , [20,20]);

medium2D=Medium(kgrid2D);
medium2D.materialIDGrid=1;
source = AcousticSource(kgrid2D);
setting=Settings;
setting.plotSimulation='on';
source.initialPressure = exp( -((kgrid2D.x).^2+kgrid2D.y.^2+kgrid2D.z.^2) ./ (10 * kgrid2D.dx).^2 );

Circle=BoundaryCondition(kgrid2D);
Circle.mask=zeros(kgrid2D.gridSize);
Circle.mask( kgrid2D.x.^2 + kgrid2D.y.^2 < (circ.radius +1*kgrid2D.dx/2)^2  )=1;
Circle.mask( kgrid2D.x.^2 + kgrid2D.y.^2 < (circ.radius -1*kgrid2D.dx/2 )^2  )=0;

Circle.normalVector=zeros([2*(radius/dx)+3+40,2*(radius/dx)+3+40,1,2]);
Circle.normalVector(21:end-20,21:end-20,:,1)=kgrid2D.x ./ sqrt( kgrid2D.x.^2 + kgrid2D.y.^2 );
Circle.normalVector(21:end-20,21:end-20,:,2)=kgrid2D.y ./ sqrt( kgrid2D.x.^2 + kgrid2D.y.^2 );
Circle.normalVector(isnan(Circle.normalVector))=0;
dt1=2e-7;
Nt1=((4*radius/medium2D.soundSpeed)/dt1);

solver=AcousticSolver(kgrid2D, medium2D, source, [],setting);
solver.setPressureBoundaryCondition(Circle)
% solver.setVelocityBoundaryCondition(Circle)
solver.run(Nt=600,dt=dt1);


for j1=7:7
    kgrid2DOG=Grid([ 2*(radius/dx + mVal(j1))+3, 2*(radius/dx + mVal(j1))+3 ],  dx , [20,20]);
    CircleOG=OffGrid(kgrid2DOG,pointcount,'circle',circ);

    medium2DOG=Medium(kgrid2DOG);
    medium2DOG.materialIDGrid=1;
    sourceOG = AcousticSource(kgrid2DOG);
    sourceOG.initialPressure = exp( -((kgrid2DOG.x).^2+kgrid2DOG.y.^2+kgrid2DOG.z.^2) ./ (10 * kgrid2DOG.dx).^2 );

    solverOG=AcousticSolver(kgrid2DOG, medium2DOG, sourceOG, [],setting);
    CircleBC=OffGridBoundaryCondition(kgrid2DOG,CircleOG,accuracy=acc(j1),staggering="forward");
    CircleBC.mask=CircleBC.maskBuilder;
    solverOG.setPressureBoundaryCondition(CircleBC)
    % solverOG.setVelocityBoundaryCondition(CircleBC)
    solverOG.run(Nt=600,dt=dt1)


    figure(7*(j1-1)+j2)
    tiledlayout(2,4)
    nexttile(2)
    imagesc(solverOG.kgrid.xVec,solverOG.kgrid.yVec,real(solverOG.pressure),[-1,0])
    colorbar
    hold on
    plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
    xlim([-circ.radius,circ.radius])
    ylim([-circ.radius,circ.radius])
    title(['accuracy = ' num2str(acc(j1))])
    nexttile(5)
    imagesc(solverOG.kgrid.xVec,solverOG.kgrid.yVec,real(solverOG.velocity(:,:,1,1)))
    colorbar
    hold on
    plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
    xlim([-circ.radius,circ.radius])
    ylim([-circ.radius,circ.radius])
    nexttile(6)
    imagesc(solverOG.kgrid.xVec,solverOG.kgrid.yVec,real(solverOG.velocity(:,:,1,2)))
    colorbar
    hold on
    plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
    xlim([-circ.radius,circ.radius])
    ylim([-circ.radius,circ.radius])

    nexttile(3)
    imagesc(solver.kgrid.xVec,solver.kgrid.yVec,solver.pressure,[-1,0])
    xlim([-circ.radius,circ.radius])
    ylim([-circ.radius,circ.radius])
    colorbar
    hold on
    plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
    title(['grid size = ' num2str(dx)])
    nexttile(7)
    imagesc(solver.kgrid.xVec,solver.kgrid.yVec,solver.velocity(:,:,1,1))
    colorbar
    hold on
    xlim([-circ.radius,circ.radius])
    ylim([-circ.radius,circ.radius])
    plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
    % nexttile(8)
    % imagesc(solver.kgrid.xVec,solver.kgrid.yVec,solver.velocity(:,:,1,2))
    % colorbar
    % hold on
    % plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
    % xlim([-circ.radius,circ.radius])
    % ylim([-circ.radius,circ.radius])

    nexttile(1)
    imagesc(solver.kgrid.xVec,solver.kgrid.yVec,-solver.source.initialPressure)
    colorbar
    hold on
    plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
    colorbar
    xlim([-circ.radius,circ.radius])
    ylim([-circ.radius,circ.radius])
    nexttile(4)
    imagesc(solverOG.kgrid.xVec,solverOG.kgrid.yVec,abs(solverOG.source.initialPressure+solverOG.pressure))
    colorbar
    hold on
    plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
    colorbar
    xlim([-circ.radius,circ.radius])
    ylim([-circ.radius,circ.radius])
    nexttile(8)
    imagesc(solver.kgrid.xVec,solver.kgrid.yVec,abs(solver.source.initialPressure+solver.pressure))
    colorbar
    hold on
    plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
    colorbar
    xlim([-circ.radius,circ.radius])
    ylim([-circ.radius,circ.radius])

    drawnow
end

end
