% Tasks: OffGrid(kgrid,[dxii,dxij],[Nxii,Nxij])
% dim = kgrid.dim-1
% PointLocs(xii,yij) in (x,y) parametrisation of surface.

% Test On Grid Boundary,

% Build OffGridBoundaryCondition < BoundaryCondition Class
% Overwrites the computational method.

% Test Off Grid.

% Numerical Comparison, off-Grid to On-Grid Boundary Condition

%%
% 
% close all
% 
% import kwave.toolbox.*
% kgrid1D = Grid(256, 1e-3,20);
% mask=zeros(kgrid1D.gridSize);
% mask(2:256/4)=1;
% % mask(3*256/4:end-1)=1;
% medium=AcousticMedium(kgrid1D);
% medium.soundSpeed=1500;
% medium.density = 1000;
% sensor=AcousticSensor(kgrid1D);
% sensor1=AcousticSensor(kgrid1D);
% sensor3=AcousticSensor(kgrid1D);
% sensor.mask=zeros(kgrid1D.gridSize);
% sensor.mask(64:192,1,1)=1;
% sensor1.mask=zeros(kgrid1D.gridSize);
% sensor1.mask(64:192,1,1)=1;
% sensor3.mask=zeros(kgrid1D.gridSize);
% sensor3.mask(64:192,1,1)=1;
% source = AcousticSource(kgrid1D);
% source.initialPressure = exp( -(kgrid1D.x.^2+kgrid1D.y.^2+kgrid1D.z.^2) ./ (10 * kgrid1D.dx).^2 );
% settings = Settings;
% settings.plotSimulation = 'on';
% solver = AcousticSolver(kgrid1D, medium, source,sensor, settings);
% BC=BoundaryCondition(kgrid1D);
% BC.mask=mask;
% solver.setPressureBoundaryCondition(BC);
% solver.run(Nt=1500,dt=1e-7)
% pause
% 
% line.startpoint=-((256*1e-3/2)*(1/2));
% line.endpoint=-((256*1e-3/2)*(1/2))-2.5e-3;
% OffGL=OffGrid(kgrid1D,6,[line.startpoint;-((256*1e-3/2)*(1/2))-5e-4;-((256*1e-3/2)*(1/2))-1e-3;-((256*1e-3/2)*(1/2))-1.5e-3;-((256*1e-3/2)*(1/2))-2e-3;line.endpoint]);
% BCOG=OffGridBoundaryCondition(kgrid1D,OffGL);
% BCOG.mask=BCOG.maskBuilder;
% solver1 = AcousticSolver(kgrid1D, medium, source, sensor1, settings);
% solver1.setPressureBoundaryCondition(BCOG);
% solver1.run(Nt=1500,dt=1e-7)
% pause
% 
% line.startPoint=-(256*1e-3/2)*(pi/6); %-pi/6 from left edge of the domain, near the halfway point from 0
% line.endPoint=-(256*1e-3/2)*(pi/6)-2.5e-3; % pi/6 from right edge of the domain, near the halfway point from 0
% % 
% % OffGL2=OffGrid(kgrid1D,6,'line',line);
% % BCOG2=OffGridBoundaryCondition(kgrid1D,OffGL2,0.01);
% % BCOG2.mask=BCOG2.maskBuilder;
% % solver2 = AcousticSolver(kgrid1D, medium, source, [], settings);
% % solver2.setPressureBoundaryCondition(BCOG2);
% % solver2.run(Nt=1000,dt=1e-7)
% line.startpoint=-(256*1e-3/2)*(pi/5); %-pi/6 from left edge of the domain, near the halfway point from 0
% % line.endpoint=-(256*1e-3/2)*(pi/5)-2.5e-3; % pi/6 from right edge of the domain, near the halfway point from 0
% OffGL3=OffGrid(kgrid1D,1,line.startpoint);
% BCOG3=OffGridBoundaryCondition(kgrid1D,OffGL3);
% BCOG3.mask=BCOG3.maskBuilder;
% solver3 = AcousticSolver(kgrid1D, medium, source, sensor3, settings);
% solver3.setPressureBoundaryCondition(BCOG3);
% solver3.run(Nt=1500,dt=1e-7)
% pause
% % figure(7)
% % plot(solver3.timeArray,solver3.sensor.pressure(:,1:(1)*1501))
% % title('1 boundary point used')
% 
% for n1=1:1:7
% line.startpoint=-(256*1e-3/2)*(pi/5); %-pi/6 from left edge of the domain, near the halfway point from 0
% line.endpoint=-(256*1e-3/2)*(pi/5)-2.5e-3; % pi/6 from right edge of the domain, near the halfway point from 0
% OffGL3=OffGrid(kgrid1D,n1+1,[line.startpoint:-2.5e-3/n1:line.endpoint]);
% BCOG3=OffGridBoundaryCondition(kgrid1D,OffGL3);
% BCOG3.mask=BCOG3.maskBuilder;
% solver3 = AcousticSolver(kgrid1D, medium, source, sensor, settings);
% solver3.setPressureBoundaryCondition(BCOG3);
% solver3.run(Nt=1500,dt=1e-7)
% pause
% % figure(7+n1)
% % plot(solver3.timeArray,solver3.sensor.pressure(:,(n1)*1501+1:(n1+1)*1501))
% % title([num2str(n1+1), ' boundary points used, over 2.5 grid points'])
% end

%%
% 
% 
clear
close all
import kwave.toolbox.*
kgrid2D = Grid([256, 256], 1e-3,[20,20]);
circ.centre=[0,0];
% circ.radius=0.025;
circ.radius=0.045;
% CircleOG=OffGrid(kgrid2D,128,'circle',circ);
% CircleOG=OffGrid(kgrid2D,157,'circle',circ);
% CircleOG=OffGrid(kgrid2D,282,'circle',circ);
medium2D=Medium(kgrid2D);
medium2D.materialIDGrid=1;
source = AcousticSource(kgrid2D);
setting=Settings;
setting.plotSimulation='on';
source.initialPressure = exp( -(kgrid2D.x.^2+kgrid2D.y.^2+kgrid2D.z.^2) ./ (10 * kgrid2D.dx).^2 );

CircleSensorOG=AcousticSensor(kgrid2D);
CircleSensorOG.mask=zeros(kgrid2D.gridSize);
CircleSensorOG.mask( kgrid2D.x.^2 + kgrid2D.y.^2 < (circ.radius/2 +1*kgrid2D.dx/2)^2  )=1;
CircleSensorOG.mask( kgrid2D.x.^2 + kgrid2D.y.^2 < (circ.radius/2 -1*kgrid2D.dx/2 )^2  )=0;
CircleSensorOG.timeSteps=2;

Circle=BoundaryCondition(kgrid2D);
Circle.mask=zeros(kgrid2D.gridSize);
Circle.mask( kgrid2D.x.^2 + kgrid2D.y.^2 < (circ.radius +1*kgrid2D.dx/2)^2  )=1;
Circle.mask( kgrid2D.x.^2 + kgrid2D.y.^2 < (circ.radius -1*kgrid2D.dx/2 )^2  )=0;
CircleForward=BoundaryCondition(kgrid2D);
CircleForward.mask=zeros(kgrid2D.gridSize);
CircleForward.mask( (kgrid2D.x+kgrid2D.dx/2).^2 + (kgrid2D.y+kgrid2D.dy/2).^2 < (circ.radius +1*kgrid2D.dx/2)^2  )=1;
CircleForward.mask( (kgrid2D.x+kgrid2D.dx/2).^2 + (kgrid2D.y+kgrid2D.dy/2).^2 < (circ.radius -1*kgrid2D.dx/2 )^2  )=0;
CircleSensor=AcousticSensor(kgrid2D);
CircleSensor.mask=zeros(kgrid2D.gridSize);
CircleSensor.mask( kgrid2D.x.^2 + kgrid2D.y.^2 < (circ.radius/2 +1*kgrid2D.dx/2)^2  )=1;
CircleSensor.mask( kgrid2D.x.^2 + kgrid2D.y.^2 < (circ.radius/2 -1*kgrid2D.dx/2 )^2  )=0;
CircleSensor.timeSteps=2;
solver3=AcousticSolver(kgrid2D, medium2D, source, CircleSensor,setting);
solver3.setPressureBoundaryCondition(Circle)
% solver3.setVelocityBoundaryCondition(CircleForward);
solver3.run(Nt=500,dt=1e-7); %On grid boundary condition velocity

POINTS=[70,141,282,290,310,330,350,370,390];
for j1=4:4
CircleOG=OffGrid(kgrid2D,POINTS(j1),'circle',circ);
solver=AcousticSolver(kgrid2D, medium2D, source, CircleSensorOG,setting);
CircleBC=OffGridBoundaryCondition(kgrid2D,CircleOG,accuracy=0.001);
CircleBC.mask=CircleBC.maskBuilder;
solver.setPressureBoundaryCondition(CircleBC)
% CircleBCFW=OffGridBoundaryCondition(kgrid2D,CircleOG,accuracy=0.01,staggering="forward");
% CircleBCFW.mask=CircleBCFW.maskBuilder;
% solver.setVelocityBoundaryCondition(CircleBCFW)
solver.run(Nt=500,dt=1e-7) %Off Grid boundary in circle, velocity boundary condition

figure(j1)
tiledlayout(2,4)
nexttile(1)
imagesc(solver.kgrid.xVec,solver.kgrid.yVec,real(solver.pressure))
colorbar
hold on
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
xlim([-circ.radius,circ.radius])
ylim([-circ.radius,circ.radius])
nexttile(5)
imagesc(solver.kgrid.xVec,solver.kgrid.yVec,real(solver.velocity(:,:,1,1)))
hold on
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
xlim([-circ.radius,circ.radius])
ylim([-circ.radius,circ.radius])
nexttile(6)
imagesc(solver.kgrid.xVec,solver.kgrid.yVec,real(solver.velocity(:,:,1,2)))
hold on
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
xlim([-circ.radius,circ.radius])
ylim([-circ.radius,circ.radius])

nexttile(3)
imagesc(solver.kgrid.xVec,solver.kgrid.yVec,solver3.pressure)
xlim([-circ.radius,circ.radius])
ylim([-circ.radius,circ.radius])
colorbar
hold on
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
nexttile(7)
imagesc(solver.kgrid.xVec,solver.kgrid.yVec,solver3.velocity(:,:,1,1))
hold on
xlim([-circ.radius,circ.radius])
ylim([-circ.radius,circ.radius])
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
nexttile(8)
imagesc(solver.kgrid.xVec,solver.kgrid.yVec,solver3.velocity(:,:,1,2))
hold on
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
xlim([-circ.radius,circ.radius])
ylim([-circ.radius,circ.radius])
nexttile(2)
imagesc(solver.kgrid.xVec,solver.kgrid.yVec,abs(solver3.pressure-solver.pressure))
hold on
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
colorbar
xlim([-circ.radius,circ.radius])
ylim([-circ.radius,circ.radius])
nexttile(4)
imagesc(solver.kgrid.xVec,solver.kgrid.yVec,log10(abs(1-solver3.pressure./solver.pressure)))
hold on
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
colorbar
xlim([-circ.radius,circ.radius])
ylim([-circ.radius,circ.radius])

drawnow

end
% 
% solver2=AcousticSolver(kgrid2D, medium2D, source, [],setting);

figure(1)
tiledlayout(2,4)
nexttile(1)
imagesc(solver.kgrid.xVec,solver.kgrid.yVec,real(solver.pressure))
colorbar
hold on
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
xlim([-circ.radius,circ.radius])
ylim([-circ.radius,circ.radius])
nexttile(5)
imagesc(solver.kgrid.xVec,solver.kgrid.yVec,real(solver.velocity(:,:,1,1)))
hold on
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
xlim([-circ.radius,circ.radius])
ylim([-circ.radius,circ.radius])
nexttile(6)
imagesc(solver.kgrid.xVec,solver.kgrid.yVec,real(solver.velocity(:,:,1,2)))
hold on
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
xlim([-circ.radius,circ.radius])
ylim([-circ.radius,circ.radius])

nexttile(3)
imagesc(solver.kgrid.xVec,solver.kgrid.yVec,solver3.pressure)
xlim([-circ.radius,circ.radius])
ylim([-circ.radius,circ.radius])
colorbar
hold on
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
nexttile(7)
imagesc(solver.kgrid.xVec,solver.kgrid.yVec,solver3.velocity(:,:,1,1))
hold on
xlim([-circ.radius,circ.radius])
ylim([-circ.radius,circ.radius])
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
nexttile(8)
imagesc(solver.kgrid.xVec,solver.kgrid.yVec,solver3.velocity(:,:,1,2))
hold on
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
xlim([-circ.radius,circ.radius])
ylim([-circ.radius,circ.radius])


nexttile(2)
imagesc(solver.kgrid.xVec,solver.kgrid.yVec,abs(solver3.pressure-solver.pressure))
hold on
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
colorbar
xlim([-circ.radius,circ.radius])
ylim([-circ.radius,circ.radius])
nexttile(4)
imagesc(solver.kgrid.xVec,solver.kgrid.yVec,log10(abs(1-solver3.pressure./solver.pressure)))
hold on
plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
colorbar
xlim([-circ.radius,circ.radius])
ylim([-circ.radius,circ.radius])

drawnow


%%

% 
% kgrid2D = Grid([129, 129], 1e-3);
% CircleOG=OffGrid(kgrid2D,128,'circle',circ);
% medium2D=Medium(kgrid2D);
% medium2D.materialIDGrid=1;
% source = AcousticSource(kgrid2D);
% setting=Settings;
% setting.plotSimulation='off';
% source.initialPressure = exp( -(kgrid2D.x.^2+kgrid2D.y.^2+kgrid2D.z.^2) ./ (10 * kgrid2D.dx).^2 );
% solver3=AcousticSolver(kgrid2D, medium2D, source, [],setting);
% CircleBC=OffGridBoundaryCondition(kgrid2D,CircleOG);
% CircleBC.mask=CircleBC.maskBuilder;
% solver3.setBoundaryCondition(CircleBC)
% solver3.run(Nt=500,dt=1e-7)
% 
% solver4=AcousticSolver(kgrid2D, medium2D, source, [],setting);
% Circle=BoundaryCondition(kgrid2D);
% Circle.mask=zeros(kgrid2D.gridSize);
% Circle.mask( kgrid2D.x.^2 + kgrid2D.y.^2 < (circ.radius +1*kgrid2D.dx/2)^2  )=1;
% Circle.mask( kgrid2D.x.^2 + kgrid2D.y.^2 < (circ.radius -1*kgrid2D.dx/2 )^2  )=0;
% solver4.setBoundaryCondition(Circle)
% solver4.run(Nt=500,dt=1e-7)
% 
% 
% figure(2)
% tiledlayout(2,4)
% nexttile(1)
% imagesc(solver3.kgrid.xVec,solver3.kgrid.yVec,real(solver3.pressure))
% colorbar
% hold on
% plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
% xlim([-circ.radius,circ.radius])
% ylim([-circ.radius,circ.radius])
% nexttile(5)
% imagesc(solver3.kgrid.xVec,solver3.kgrid.yVec,real(solver3.velocity(:,:,1,1)))
% hold on
% plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
% xlim([-circ.radius,circ.radius])
% ylim([-circ.radius,circ.radius])
% nexttile(6)
% imagesc(solver3.kgrid.xVec,solver3.kgrid.yVec,real(solver3.velocity(:,:,1,2)))
% hold on
% plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
% xlim([-circ.radius,circ.radius])
% ylim([-circ.radius,circ.radius])
% 
% nexttile(3)
% imagesc(solver3.kgrid.xVec,solver3.kgrid.yVec,solver4.pressure)
% colorbar
% hold on
% plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
% xlim([-circ.radius,circ.radius])
% ylim([-circ.radius,circ.radius])
% nexttile(7)
% imagesc(solver3.kgrid.xVec,solver3.kgrid.yVec,solver4.velocity(:,:,1,1))
% hold on
% plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
% xlim([-circ.radius,circ.radius])
% ylim([-circ.radius,circ.radius])
% nexttile(8)
% imagesc(solver3.kgrid.xVec,solver3.kgrid.yVec,solver4.velocity(:,:,1,2))
% hold on
% plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
% xlim([-circ.radius,circ.radius])
% ylim([-circ.radius,circ.radius])
% 
% 
% nexttile(2)
% imagesc(solver.kgrid.xVec,solver.kgrid.yVec,abs(solver3.pressure-solver4.pressure))
% hold on
% plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
% colorbar
% xlim([-circ.radius,circ.radius])
% ylim([-circ.radius,circ.radius])
% nexttile(4)
% imagesc(solver.kgrid.xVec,solver.kgrid.yVec,log10(abs(1-solver4.pressure./solver3.pressure)))
% hold on
% plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
% colorbar
% xlim([-circ.radius,circ.radius])
% ylim([-circ.radius,circ.radius])
%

%%
% 
% 
% clear
% close all
% import kwave.toolbox.*
% kgrid2D = Grid([325, 325], 1e-3);
% circ.centre=[0,0];
% circ.radius=0.025;
% CircleOG=OffGrid(kgrid2D,128,'circle',circ);
% medium2D=Medium(kgrid2D);
% medium2D.materialIDGrid=1;
% source = AcousticSource(kgrid2D);
% setting=Settings;
% setting.plotSimulation='off';
% source.initialPressure = exp( -(kgrid2D.x.^2+kgrid2D.y.^2+kgrid2D.z.^2) ./ (10 * kgrid2D.dx).^2 );
% 
% solver1=AcousticSolver(kgrid2D, medium2D, source, [],setting);
% CircleBCL=OffGridBoundaryCondition(kgrid2D,CircleOG,accuracy=0.1);
% CircleBCL.mask=CircleBCL.maskBuilder;
% solver1.setPressureBoundaryCondition(CircleBCL);
% 
% solver2=AcousticSolver(kgrid2D, medium2D, source, [],setting);
% CircleBCM=OffGridBoundaryCondition(kgrid2D,CircleOG,accuracy=0.01);
% CircleBCM.mask=CircleBCM.maskBuilder;
% solver2.setPressureBoundaryCondition(CircleBCM);
% 
% solver3=AcousticSolver(kgrid2D, medium2D, source, [],setting);
% CircleBCH=OffGridBoundaryCondition(kgrid2D,CircleOG,accuracy=0.0025);
% CircleBCH.mask=CircleBCH.maskBuilder;
% solver3.setPressureBoundaryCondition(CircleBCH);
% 
% solver1.run(Nt=150,dt=1e-7)
% solver2.run(Nt=150,dt=1e-7)
% solver3.run(Nt=150,dt=1e-7)
% 
% figure(2)
% tiledlayout(2,3)
% nexttile(1)
% imagesc(solver3.kgrid.xVec,solver3.kgrid.yVec,real(solver1.pressure))
% colorbar
% hold on
% plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
% xlim([-circ.radius,circ.radius])
% ylim([-circ.radius,circ.radius])
% 
% nexttile(2)
% imagesc(solver3.kgrid.xVec,solver3.kgrid.yVec,real(solver2.pressure))
% colorbar
% hold on
% plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
% xlim([-circ.radius,circ.radius])
% ylim([-circ.radius,circ.radius])
% 
% nexttile(3)
% imagesc(solver3.kgrid.xVec,solver3.kgrid.yVec,real(solver3.pressure))
% colorbar
% hold on
% plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
% xlim([-circ.radius,circ.radius])
% ylim([-circ.radius,circ.radius])
% 
% nexttile(4)
% imagesc(solver3.kgrid.xVec,solver3.kgrid.yVec,abs(solver1.pressure-solver3.pressure))
% colorbar
% hold on
% plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
% xlim([-circ.radius,circ.radius])
% ylim([-circ.radius,circ.radius])
% 
% nexttile(5)
% imagesc(solver3.kgrid.xVec,solver3.kgrid.yVec,abs(solver2.pressure-solver3.pressure))
% colorbar
% hold on
% plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
% xlim([-circ.radius,circ.radius])
% ylim([-circ.radius,circ.radius])
%%
% 
% 
% clear
% close all
% import kwave.toolbox.*
% 
% kgrid2D = Grid([284, 225], 1e-3,[20,0]);
% 
% 
% sensorLocation=[60,-15]*kgrid2D.dx;
% 
% linepoint1=(sensorLocation(1));
% linepoint2=(2*sensorLocation(2));
% diag=tan( pi/4 - 1/2 * atan( sensorLocation(2)/sensorLocation(1) ) );
% 
% line.startPoint=[ linepoint1 , linepoint1*diag  ];
% line.endPoint=[linepoint2/diag,linepoint2];
% 
% LineOG=OffGrid(kgrid2D,110,'line',line);
% medium2D=Medium(kgrid2D);
% medium2D.materialIDGrid=1;
% source = AcousticSource(kgrid2D);
% setting=Settings;
% setting.plotSimulation='on';
% source.initialPressure = exp( -(kgrid2D.x-4*kgrid2D.Nx*kgrid2D.dx/14).^2 ./ (10 * kgrid2D.dx).^2 );
% 
% LineBC2=BoundaryCondition(kgrid2D);
% LineBC2.mask=zeros(kgrid2D.gridSize);
% for jx=1:kgrid2D.Nx
%     for  jy=1:kgrid2D.Ny
%         if kgrid2D.xVec(jx)<line.startPoint(1)+kgrid2D.dx && kgrid2D.yVec(jy)<line.startPoint(2)+kgrid2D.dx && kgrid2D.xVec(jx)>line.endPoint(1)-kgrid2D.dx && kgrid2D.yVec(jy)>line.endPoint(2)-kgrid2D.dx
%             if abs(( kgrid2D.yVec(jy) ) - diag * ( kgrid2D.xVec(jx) )) < kgrid2D.dx/2
%                 LineBC2.mask(jx,jy)=1;
%             end
%         end
%     end
% end
% 
% solverBasic=AcousticSolver(kgrid2D, medium2D, source, [],setting);
% solverBasic.setPressureBoundaryCondition(LineBC2);
% solverBasic.run(Nt=400,dt=(0.75)*(0.5)*1e-3/1500);
% 
% setting.plotSimulation='off';
% 
% LineBC=OffGridBoundaryCondition(kgrid2D,LineOG,accuracy=0.01);
% LineBC.mask=LineBC.maskBuilder;
% solver1=AcousticSolver(kgrid2D, medium2D, source, [],setting);
% solver1.setPressureBoundaryCondition(LineBC);
% solver1.run(Nt=400,dt=(0.75)*(0.5)*1e-3/1500);
% 
% LineBC=OffGridBoundaryCondition(kgrid2D,LineOG,accuracy=0.008);
% LineBC.mask=LineBC.maskBuilder;
% solver2=AcousticSolver(kgrid2D, medium2D, source, [],setting);
% solver2.setPressureBoundaryCondition(LineBC);
% solver2.run(Nt=250,dt=(0.75)*(0.5)*1e-3/1500);
% 
% LineBC=OffGridBoundaryCondition(kgrid2D,LineOG,accuracy=0.006);
% LineBC.mask=LineBC.maskBuilder;
% solver3=AcousticSolver(kgrid2D, medium2D, source, [],setting);
% solver3.setPressureBoundaryCondition(LineBC);
% solver3.run(Nt=250,dt=(0.75)*(0.5)*1e-3/1500);
% 
% LineBC=OffGridBoundaryCondition(kgrid2D,LineOG,accurarcy=0.005);
% LineBC.mask=LineBC.maskBuilder;
% solver4=AcousticSolver(kgrid2D, medium2D, source, [],setting);
% solver4.setPressureBoundaryCondition(LineBC);
% solver4.run(Nt=250,dt=(0.75)*(0.5)*1e-3/1500);
% 
% LineBC=OffGridBoundaryCondition(kgrid2D,LineOG,accuracy=0.004);
% LineBC.mask=LineBC.maskBuilder;
% solver5=AcousticSolver(kgrid2D, medium2D, source, [],setting);
% solver5.setPressureBoundaryCondition(LineBC);
% solver5.run(Nt=250,dt=(0.75)*(0.5)*1e-3/1500);
% 
% figure
% tiledlayout(1,3)
% nexttile(1)
% imagesc(kgrid2D.yVec,kgrid2D.xVec,real(solver1.pressure))
% hold on
% plot(LineOG.kgridLocations(:,2),LineOG.kgridLocations(:,1),'w-')
% xlim([-0.075,0.075])
% ylim([-0.03,0.03])
% colorbar
% nexttile(3)
% imagesc(kgrid2D.yVec,kgrid2D.xVec,real(solverBasic.pressure))
% hold on
% plot(LineOG.kgridLocations(:,2),LineOG.kgridLocations(:,1),'w-')
% xlim([-0.075,0.075])
% ylim([-0.03,0.03])
% colorbar
% nexttile(2)
% imagesc(kgrid2D.yVec,kgrid2D.xVec,log10(abs(1-solverBasic.pressure./solver1.pressure)))
% hold on
% plot(LineOG.kgridLocations(:,2),LineOG.kgridLocations(:,1),'w-')
% colorbar
% xlim([-0.075,0.075])
% ylim([-0.03,0.03])
% 
% figure
% tiledlayout(2,3)
% nexttile(1)
% imagesc((solver5.pressure))
% colorbar
% nexttile(2)
% imagesc(abs(solver5.pressure-solverBasic.pressure))
% colorbar
% nexttile(3)
% imagesc(abs(solver5.pressure-solver1.pressure))
% colorbar
% nexttile(4)
% imagesc(abs(solver5.pressure-solver2.pressure))
% colorbar
% nexttile(5)
% imagesc(abs(solver5.pressure-solver3.pressure))
% colorbar
% nexttile(6)
% imagesc(abs(solver5.pressure-solver4.pressure))
% colorbar