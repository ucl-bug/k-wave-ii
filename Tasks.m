% Tasks: OffGrid(kgrid,[dxii,dxij],[Nxii,Nxij])
% dim = kgrid.dim-1
% PointLocs(xii,yij) in (x,y) parametrisation of surface.

% Test On Grid Boundary,

% Build OffGridBoundaryCondition < BoundaryCondition Class
% Overwrites the computational method.

% Test Off Grid.

% Numerical Comparison, off-Grid to On-Grid Boundary Condition

% close all
% 
% import kwave.toolbox.*
% kgrid1D = Grid([256], 1e-3,20);
% mask=zeros(kgrid1D.gridSize);
% mask(256/4)=1;
% mask(3*256/4)=1;
% medium=AcousticMedium(kgrid1D);
% medium.soundSpeed=1500;
% medium.density = 1000;
% source = AcousticSource(kgrid1D);
% source.initialPressure = exp( -(kgrid1D.x.^2+kgrid1D.y.^2+kgrid1D.z.^2) ./ (10 * kgrid1D.dx).^2 );
% settings = Settings;
% settings.plotSimulation = 'on';
% solver = AcousticSolver(kgrid1D, medium, source, settings);
% BC=BoundaryCondition(kgrid1D);
% BC.mask=mask;
% solver.setBoundaryCondition(BC);
% solver.run(Nt=1000,dt=1e-7)
% 
% line.startpoint=-((256*1e-3/2)*(1/2));
% line.endpoint=((256*1e-3/2)*(1/2));
% OffGL=OffGrid(kgrid1D,2,[line.startpoint;line.endpoint]);
% BCOG=OffGridBoundaryCondition(kgrid1D,OffGL);
% BCOG.mask=BCOG.maskBuilder;
% solver1 = AcousticSolver(kgrid1D, medium, source, settings);
% solver1.setBoundaryCondition(BCOG);
% solver1.run(Nt=1000,dt=1e-7)
% 
% line.startpoint=-(256*1e-3/2)*(pi/6); %-pi/6 from left edge of the domain, near the halfway point from 0
% line.endpoint=(256*1e-3/2)*(pi/6); % pi/6 from right edge of the domain, near the halfway point from 0
% 
% OffGL2=OffGrid(kgrid1D,2,[line.startpoint;line.endpoint]);
% BCOG2=OffGridBoundaryCondition(kgrid1D,OffGL2);
% BCOG2.mask=BCOG2.maskBuilder;
% solver2 = AcousticSolver(kgrid1D, medium, source, settings);
% solver2.setBoundaryCondition(BCOG2);
% solver2.run(Nt=1000,dt=1e-7)
% 
% line.startpoint=-(256*1e-3/2)*(pi/5); %-pi/6 from left edge of the domain, near the halfway point from 0
% line.endpoint=(256*1e-3/2)*(pi/5); % pi/6 from right edge of the domain, near the halfway point from 0
% OffGL3=OffGrid(kgrid1D,2,[line.startpoint;line.endpoint]);
% BCOG3=OffGridBoundaryCondition(kgrid1D,OffGL3);
% BCOG3.mask=BCOG3.maskBuilder;
% solver3 = AcousticSolver(kgrid1D, medium, source, settings);
% solver3.setBoundaryCondition(BCOG3);
% solver3.run(Nt=1000,dt=1e-7)



clear
close all
import kwave.toolbox.*
kgrid2D = Grid([128, 128], 1e-3);
circ.centre=[0,0];
% circ.radius=0.025;
circ.radius=0.045;
CircleOG=OffGrid(kgrid2D,128,'circle',circ);
medium2D=Medium(kgrid2D);
medium2D.materialIDGrid=1;
source = AcousticSource(kgrid2D);
setting=Settings;
setting.plotSimulation='off';
source.initialPressure = exp( -(kgrid2D.x.^2+kgrid2D.y.^2+kgrid2D.z.^2) ./ (10 * kgrid2D.dx).^2 );
solver=AcousticSolver(kgrid2D, medium2D, source, [],setting);
CircleBC=OffGridBoundaryCondition(kgrid2D,CircleOG);
CircleBC.mask=CircleBC.maskBuilder;
solver.setBoundaryCondition(CircleBC)
solver.run(Nt=500,dt=1e-7)

solver2=AcousticSolver(kgrid2D, medium2D, source, [],setting);
Circle=BoundaryCondition(kgrid2D);
Circle.mask=zeros(kgrid2D.gridSize);
Circle.mask( kgrid2D.x.^2 + kgrid2D.y.^2 < (circ.radius +1*kgrid2D.dx/2)^2  )=1;
Circle.mask( kgrid2D.x.^2 + kgrid2D.y.^2 < (circ.radius -1*kgrid2D.dx/2 )^2  )=0;
solver2.setBoundaryCondition(Circle)
solver2.run(Nt=500,dt=1e-7)


figure(1)
tiledlayout(2,4)
nexttile(1)
imagesc(solver.kgrid.xVec,solver.kgrid.yVec,real(solver.pressure))
colorbar
hold on
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
nexttile(5)
imagesc(solver.kgrid.xVec,solver.kgrid.yVec,real(solver.velocity(:,:,1,1)))
hold on
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
nexttile(6)
imagesc(solver.kgrid.xVec,solver.kgrid.yVec,real(solver.velocity(:,:,1,2)))
hold on
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')

nexttile(3)
imagesc(solver.kgrid.xVec,solver.kgrid.yVec,solver2.pressure)
colorbar
hold on
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
nexttile(7)
imagesc(solver.kgrid.xVec,solver.kgrid.yVec,solver2.velocity(:,:,1,1))
hold on
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
nexttile(8)
imagesc(solver.kgrid.xVec,solver.kgrid.yVec,solver2.velocity(:,:,1,2))
hold on
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')


nexttile(2)
imagesc(solver.kgrid.xVec,solver.kgrid.yVec,(solver2.pressure-solver.pressure))
hold on
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
colorbar
nexttile(4)
imagesc(solver.kgrid.xVec,solver.kgrid.yVec,log10(abs(1-solver2.pressure./solver.pressure)))
hold on
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
colorbar

%%

kgrid2D = Grid([129, 129], 1e-3);
CircleOG=OffGrid(kgrid2D,128,'circle',circ);
medium2D=Medium(kgrid2D);
medium2D.materialIDGrid=1;
source = AcousticSource(kgrid2D);
setting=Settings;
setting.plotSimulation='off';
source.initialPressure = exp( -(kgrid2D.x.^2+kgrid2D.y.^2+kgrid2D.z.^2) ./ (10 * kgrid2D.dx).^2 );
solver3=AcousticSolver(kgrid2D, medium2D, source, [],setting);
CircleBC=OffGridBoundaryCondition(kgrid2D,CircleOG);
CircleBC.mask=CircleBC.maskBuilder;
solver3.setBoundaryCondition(CircleBC)
solver3.run(Nt=500,dt=1e-7)

solver4=AcousticSolver(kgrid2D, medium2D, source, [],setting);
Circle=BoundaryCondition(kgrid2D);
Circle.mask=zeros(kgrid2D.gridSize);
Circle.mask( kgrid2D.x.^2 + kgrid2D.y.^2 < (circ.radius +1*kgrid2D.dx/2)^2  )=1;
Circle.mask( kgrid2D.x.^2 + kgrid2D.y.^2 < (circ.radius -1*kgrid2D.dx/2 )^2  )=0;
solver4.setBoundaryCondition(Circle)
solver4.run(Nt=500,dt=1e-7)


figure(2)
tiledlayout(2,4)
nexttile(1)
imagesc(solver3.kgrid.xVec,solver3.kgrid.yVec,real(solver3.pressure))
colorbar
hold on
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
nexttile(5)
imagesc(solver3.kgrid.xVec,solver3.kgrid.yVec,real(solver3.velocity(:,:,1,1)))
hold on
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
nexttile(6)
imagesc(solver3.kgrid.xVec,solver3.kgrid.yVec,real(solver3.velocity(:,:,1,2)))
hold on
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')

nexttile(3)
imagesc(solver3.kgrid.xVec,solver3.kgrid.yVec,solver4.pressure)
colorbar
hold on
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
nexttile(7)
imagesc(solver3.kgrid.xVec,solver3.kgrid.yVec,solver4.velocity(:,:,1,1))
hold on
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
nexttile(8)
imagesc(solver3.kgrid.xVec,solver3.kgrid.yVec,solver4.velocity(:,:,1,2))
hold on
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')


nexttile(2)
imagesc(solver.kgrid.xVec,solver.kgrid.yVec,(solver3.pressure-solver4.pressure))
hold on
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
colourbar
nexttile(4)
imagesc(solver.kgrid.xVec,solver.kgrid.yVec,log10(abs(1-solver3.pressure./solver4.pressure)))
hold on
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
colorbar
