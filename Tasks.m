% Tasks: OffGrid(kgrid,[dxii,dxij],[Nxii,Nxij])
% dim = kgrid.dim-1
% PointLocs(xii,yij) in (x,y) parametrisation of surface.

% Test On Grid Boundary,

% Build OffGridBoundaryCondition < BoundaryCondition Class
% Overwrites the computational method.

% Test Off Grid.

% Numerical Comparison, off-Grid to On-Grid Boundary Condition



import kwave.toolbox.*
kgrid1D = Grid([256], 1e-3,20);
mask=zeros(kgrid1D.gridSize);
mask(256/4)=1;
mask(3*256/4)=1;
medium=AcousticMedium(kgrid1D);
medium.soundSpeed=1500;
medium.density = 1000;
source = AcousticSource(kgrid1D);
source.initialPressure = exp( -(kgrid1D.x.^2+kgrid1D.y.^2+kgrid1D.z.^2) ./ (10 * kgrid1D.dx).^2 );
settings = Settings;
settings.plotSimulation = 'on';
solver = AcousticSolver(kgrid1D, medium, source, settings);
BC=BoundaryCondition(kgrid1D);
BC.mask=mask;
solver.setBoundaryCondition(BC);
solver.run(Nt=3500,dt=1e-7)

line.startpoint=-((256*1e-3/2)*(1/2));
line.endpoint=((256*1e-3/2)*(1/2));
OffGL=OffGrid(kgrid1D,2,[line.startpoint;line.endpoint]);
BCOG=OffGridBoundaryCondition(kgrid1D,OffGL);
BCOG.mask=BCOG.maskBuilder;
solver = AcousticSolver(kgrid1D, medium, source, settings);
solver.setBoundaryCondition(BCOG);
solver.run(Nt=3500,dt=1e-7)

line.startpoint=-(256*1e-3/2)*(pi/6); %-pi/6 from left edge of the domain, near the halfway point from 0
line.endpoint=(256*1e-3/2)*(pi/6); % pi/6 from right edge of the domain, near the halfway point from 0

OffGL2=OffGrid(kgrid1D,2,[line.startpoint;line.endpoint]);
BCOG2=OffGridBoundaryCondition(kgrid1D,OffGL2);
BCOG2.mask=BCOG2.maskBuilder;
solver = AcousticSolver(kgrid1D, medium, source, settings);
solver.setBoundaryCondition(BCOG);
solver.run(Nt=3500,dt=1e-7)