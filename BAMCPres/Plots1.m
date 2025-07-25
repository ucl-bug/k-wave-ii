%%

clear
close all
import kwave.toolbox.*

acc=0.005;
dx=1e-4;
Nx=256;

x1=-1*(Nx/2*dx)/2;
x2=1*(Nx/2*dx)/2;
y1=-x1/2;
y2=-x2/2;


kgrid2D=Grid( [Nx, Nx],  dx , [20,20]);

medium2D=Medium(kgrid2D);
medium2D.materialIDGrid=1;
source = AcousticSource(kgrid2D);
setting=Settings;
setting.plotSimulation='on';
source.initialPressure = zeros(kgrid2D.gridSize);
source.initialPressure(kgrid2D.x<3*x1/2)=1;
source.initialPressure(kgrid2D.x<3*x1/2-2*dx)=0;
LineSeg=BoundaryCondition(kgrid2D);
LineSeg.mask=zeros(kgrid2D.gridSize);
LineSeg.mask( abs(kgrid2D.x + 2*kgrid2D.y) < 1.5*kgrid2D.dx  )=1;
LineSeg.mask(  kgrid2D.x< x1  )=0;
LineSeg.mask(  kgrid2D.x> x2  )=0;
dt1=0.5e-7;
Nt1=150;
solver=AcousticSolver(kgrid2D, medium2D, source, [],setting);
solver.setPressureBoundaryCondition(LineSeg)
solver.run(Nt=Nt1,dt=dt1);

solver2=AcousticSolver(kgrid2D, medium2D, source, [],setting);
line.startPoint=[x1,y1];
line.endPoint=[x2,y2];
length=floor(sqrt((x2-x1)^2 + (y2-y1)^2)/dx);
LineSegment=OffGrid(kgrid2D,length,'line',line);
LineBC=OffGridBoundaryCondition(kgrid2D,LineSegment,accuracy=acc);
LineBC.mask=LineBC.maskBuilder;
solver2.setPressureBoundaryCondition(LineBC);
solver2.run(Nt=Nt1,dt=dt1);

figure(1)
hold on
plot(linspace(y1,y2,50),linspace(x1,x2,50),'k')
xlim([-0.005,0])
ylim([-0.005,0.005])

figure(2)
hold on
plot(linspace(y1,y2,50),linspace(x1,x2,50),'k')
xlim([-0.005,0])
ylim([-0.005,0.005])
