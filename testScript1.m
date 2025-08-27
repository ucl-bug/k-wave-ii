import kwave.toolbox.*


Nax = 256;
Nlat= 31;
PointDist=100/3;

dx = 4e-3;
c0 = 1500;
rho0 = 1000;
pmlSize = 20;
CFL = 0.5;
%Nt = 150;
dt = CFL * dx / c0;
settings = Settings;
settings.plotSimulation = 'on';

kgrid2D = Grid([Nax,Nlat], dx, [pmlSize,0]);
medium2D = AcousticMedium(kgrid2D);
medium2D.soundSpeed  = c0;
medium2D.density  = rho0;
source2D = AcousticSource(kgrid2D);
source2D.initialPressure=0;
initialPressure = @(x,y) exp( -(( x).^2 + (y.'.^2)) ./ (10* kgrid2D.dx).^2 );
source2D.initialPressure =  initialPressure(kgrid2D.xVec,kgrid2D.yVec);
Nt = round(((Nax-2*PointDist) )/CFL);

source2D.initialPressure=0;
source2D.initialPressure =  initialPressure(kgrid2D.x,0);
line1.startPoint=[-(floor(Nax/2)-PointDist)*dx,-floor(Nlat/2)*dx];
line1.endPoint=[-(floor(Nax/2)-PointDist)*dx,floor(Nlat/2)*dx];
line2.startPoint=[(floor(Nax/2)-PointDist)*dx,-floor(Nlat/2)*dx];
line2.endPoint=[(floor(Nax/2)-PointDist)*dx,floor(Nlat/2)*dx];
line1.points=floor(Nlat);
line2.points=floor(Nlat);
OffPoints1=OffGrid(kgrid2D,'line',line1);
OffPoints2=OffGrid(kgrid2D,'line',line2);
OffPoints=OffGrid(kgrid2D,OffPoints1,OffPoints2);
AcousticBoundary2DOff=AcousticBndryCond(kgrid2D);
AcousticBoundary2DOff.pressureBndry = 'on';
AcousticBoundary2DOff.setOffGrid(OffPoints,0.00125);
AcousticBoundary2DOff.mask=AcousticBoundary2DOff.maskBuilder;
solver2DOG = AcousticSolver(kgrid2D, medium2D, source2D, [], settings);
solver2DOG.applyBoundaryCondition(AcousticBoundary2DOff)
solver2DOG.run(Nt=Nt, dt=dt);
results = solver2DOG.pressure;
expectedResults=-solver2DOG.source.initialPressure;

%%

kgrid2D = Grid([Nlat,Nax], dx, [0,pmlSize]);
medium2D = AcousticMedium(kgrid2D);
medium2D.soundSpeed  = c0;
medium2D.density  = rho0;
source2D = AcousticSource(kgrid2D);
source2D.initialPressure=0;
source2D.initialPressure =  initialPressure(kgrid2D.y,0);
line3.startPoint=[-floor(Nlat/2)*dx,-(floor(Nax/2)-PointDist)*dx];
line3.endPoint=[floor(Nlat/2)*dx,-(floor(Nax/2)-PointDist)*dx];
line4.startPoint=[-floor(Nlat/2)*dx,(floor(Nax/2)-PointDist)*dx];
line4.endPoint=[floor(Nlat/2)*dx,(floor(Nax/2)-PointDist)*dx];
line3.points=floor(Nlat);
line4.points=floor(Nlat);
OffPoints3=OffGrid(kgrid2D,'line',line3);
OffPoints4=OffGrid(kgrid2D,'line',line4);
OffPointsNew=OffGrid(kgrid2D,OffPoints3,OffPoints4);
AcousticBoundary2DOff2=AcousticBndryCond(kgrid2D);
AcousticBoundary2DOff2.pressureBndry = 'on';
AcousticBoundary2DOff2.setOffGrid(OffPointsNew,0.00125);
AcousticBoundary2DOff2.mask=AcousticBoundary2DOff2.maskBuilder;
solver2DOG2 = AcousticSolver(kgrid2D, medium2D, source2D, [], settings);
solver2DOG2.applyBoundaryCondition(AcousticBoundary2DOff2)
solver2DOG2.run(Nt=Nt, dt=dt);
results = solver2DOG2.pressure;
expectedResults=-solver2DOG2.source.initialPressure;



% radius=(Nax/2-PointDist)*dx;
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

