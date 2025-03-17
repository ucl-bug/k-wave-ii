close all

import kwave.toolbox.*
kgrid1D = Grid(256, 1e-3,20);
mask=zeros(kgrid1D.gridSize);
mask(2:256/4)=1;
% mask(3*256/4:end-1)=1;
medium=AcousticMedium(kgrid1D);
medium.soundSpeed=1500;
medium.density = 1000;
sensor=AcousticSensor(kgrid1D);
sensor1=AcousticSensor(kgrid1D);
sensor3=AcousticSensor(kgrid1D);
sensor.mask=zeros(kgrid1D.gridSize);
sensor.mask(64:192,1,1)=1;
sensor1.mask=zeros(kgrid1D.gridSize);
sensor1.mask(64:192,1,1)=1;
sensor3.mask=zeros(kgrid1D.gridSize);
sensor3.mask(64:192,1,1)=1;
source = AcousticSource(kgrid1D);
source.initialPressure = exp( -(kgrid1D.x.^2+kgrid1D.y.^2+kgrid1D.z.^2) ./ (10 * kgrid1D.dx).^2 );
settings = Settings;
settings.plotSimulation = 'on';
solver = AcousticSolver(kgrid1D, medium, source,sensor, settings);
BC=BoundaryCondition(kgrid1D);
BC.mask=mask;
solver.setPressureBoundaryCondition(BC);
solver.run(Nt=1500,dt=1e-7)
pause

line.startpoint=-((256*1e-3/2)*(1/2));
line.endpoint=-((256*1e-3/2)*(1/2))-2.5e-3;
OffGL=OffGrid(kgrid1D,6,[line.startpoint;-((256*1e-3/2)*(1/2))-5e-4;-((256*1e-3/2)*(1/2))-1e-3;-((256*1e-3/2)*(1/2))-1.5e-3;-((256*1e-3/2)*(1/2))-2e-3;line.endpoint]);
BCOG=OffGridBoundaryCondition(kgrid1D,OffGL);
BCOG.mask=BCOG.maskBuilder;
solver1 = AcousticSolver(kgrid1D, medium, source, sensor1, settings);
solver1.setPressureBoundaryCondition(BCOG);
solver1.run(Nt=1500,dt=1e-7)
pause

line.startPoint=-(256*1e-3/2)*(pi/6); %-pi/6 from left edge of the domain, near the halfway point from 0
line.endPoint=-(256*1e-3/2)*(pi/6)-2.5e-3; % pi/6 from right edge of the domain, near the halfway point from 0
% 
% OffGL2=OffGrid(kgrid1D,6,'line',line);
% BCOG2=OffGridBoundaryCondition(kgrid1D,OffGL2,0.01);
% BCOG2.mask=BCOG2.maskBuilder;
% solver2 = AcousticSolver(kgrid1D, medium, source, [], settings);
% solver2.setPressureBoundaryCondition(BCOG2);
% solver2.run(Nt=1000,dt=1e-7)
line.startpoint=-(256*1e-3/2)*(pi/5); %-pi/6 from left edge of the domain, near the halfway point from 0
% line.endpoint=-(256*1e-3/2)*(pi/5)-2.5e-3; % pi/6 from right edge of the domain, near the halfway point from 0
OffGL3=OffGrid(kgrid1D,1,line.startpoint);
BCOG3=OffGridBoundaryCondition(kgrid1D,OffGL3);
BCOG3.mask=BCOG3.maskBuilder;
solver3 = AcousticSolver(kgrid1D, medium, source, sensor3, settings);
solver3.setPressureBoundaryCondition(BCOG3);
solver3.run(Nt=1500,dt=1e-7)
pause
% figure(7)
% plot(solver3.timeArray,solver3.sensor.pressure(:,1:(1)*1501))
% title('1 boundary point used')

for n1=1:1:7
line.startpoint=-(256*1e-3/2)*(pi/5); %-pi/6 from left edge of the domain, near the halfway point from 0
line.endpoint=-(256*1e-3/2)*(pi/5)-2.5e-3; % pi/6 from right edge of the domain, near the halfway point from 0
OffGL3=OffGrid(kgrid1D,n1+1,[line.startpoint:-2.5e-3/n1:line.endpoint]);
BCOG3=OffGridBoundaryCondition(kgrid1D,OffGL3);
BCOG3.mask=BCOG3.maskBuilder;
solver3 = AcousticSolver(kgrid1D, medium, source, sensor, settings);
solver3.setPressureBoundaryCondition(BCOG3);
solver3.run(Nt=1500,dt=1e-7)
pause
% figure(7+n1)
% plot(solver3.timeArray,solver3.sensor.pressure(:,(n1)*1501+1:(n1+1)*1501))
% title([num2str(n1+1), ' boundary points used, over 2.5 grid points'])
end