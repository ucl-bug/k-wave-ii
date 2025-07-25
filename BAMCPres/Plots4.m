%%

clear
close all
import kwave.toolbox.*

dx=1e-3;
Nx=256;


kgrid1D=Grid( Nx,  dx , 20);

medium1D=Medium(kgrid1D);
medium1D.materialIDGrid=1;
source = AcousticSource(kgrid1D);
setting=Settings;
setting.plotSimulation='on';
source.initialPressure = zeros(kgrid1D.gridSize);
source.initialPressure=exp(-kgrid1D.x.^2/(10*dx^2));
% source.initialPressure=smooth(source.initialPressure);
dt1=1e-7;
Nt1=750;




% A= [-Nx*dx*(pi/8)/2; -Nx*dx*(pi/8)/2-dx/2; -Nx*dx*(pi/8)/2-dx; Nx*dx*(pi/8)/2; Nx*dx*(pi/8)/2 + dx/2 ;Nx*dx*(pi/8)/2+dx  ];  
A= [-Nx*dx*(pi/6)/2;Nx*dx*(pi/6)/2];

for n1=1:1
    solver=AcousticSolver(kgrid1D, medium1D, source, [],setting);
    solver2=AcousticSolver(kgrid1D, medium1D, source, [],setting);
    line.startpoint=-(Nx*dx/2)*(pi/6); %-pi/6 from left edge of the domain, near the halfway point from 0
    line.endpoint=-(Nx*dx/2)*(pi/6)-5*dx/2; % pi/6 from right edge of the domain, near the halfway point from 0
    Points=OffGrid(kgrid1D,length(A),A);
    OffGL3=OffGrid(kgrid1D,n1+1,[line.startpoint:-(5*dx/2)/n1:line.endpoint]);
    BCOG3=OffGridBoundaryCondition(kgrid1D,OffGL3);
    PointsBC=OffGridBoundaryCondition(kgrid1D,Points);
    BCOG3.mask=BCOG3.maskBuilder;
    PointsBC.mask=PointsBC.maskBuilder;
    solver.setPressureBoundaryCondition(BCOG3);
    %solver.run(Nt=Nt1,dt=dt1);
    solver2.setPressureBoundaryCondition(PointsBC);
    solver2.run(Nt=Nt1,dt=dt1);
end



% PositionsBC=OffGridBoundaryCondition(kgrid1D,Points,accuracy=acc);
% PositionsBC.mask=PositionsBC.maskBuilder;
% solver.setPressureBoundaryCondition(PositionsBC);

