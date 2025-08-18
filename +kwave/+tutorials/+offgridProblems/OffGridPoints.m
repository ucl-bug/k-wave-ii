%% Acoustic Solver example
%
%% Overview
% This example is design to introduce the various set-up methods for
% problems that make use of the off-grid classes. Off-grid classes are used
% in Off-Grid Sensors, Off-Grid Sources and Off-Grid Boundary Conditions,
% but each require the initial construction of the off-grid domain.
% The Off-grid class defines the points that are associated with the
% off grid locations. This may be a single point, or a collection of points
% within the space that is usually discretised by the grid.
%
% It is important to ensure all of the off-grid locations are contained
% within the grid such that the interactions between the off-grid and grid
% locations can be defined. The problem will otherwise error.
%
% THe OffGrid class works by providing the list of points, as well as how
% many points are expected. There are also a number of inbuilt defaults
% that can build common shapes.
%
% See Also:
% * +intialvalueproblems/AcosusicSolverExamples.m
%

%% Setup
%
% First we required access to the classes and functions of the k-Wave II
% toolbox.

clearvars;
import kwave.toolbox.*

% Next we must define a grid as our workspace, In these examples we use
% kgrid1D, kgrid2D and kgrid3D as our domains, which each have all
% dimensions with width 1m around 0, resulting in a line, square and cube
% domain. The actual size of the gridspacing and the number of grid points
% is not relevent, however increased gridpoints in practice will produce
% better results.

kgrid1D=Grid(200,5e-3,0);
kgrid2D=Grid([200,200],5e-3,0);
kgrid3D=Grid([200,200,200],5e-3,0);

% The first examples of building an Off-Grid will  be through providing a
% list of grid points

points1D=linspace(-0.4,.4,15);

Set2=linspace(-0.3,0.3,8);
Set3=linspace(-0.2,0.2,4);

points2D=zeros(15*8,2);
points3D=zeros(15*8*4,3);
for j1=0:7
    points2D(j1*15+1:(j1+1)*15,1)=points1D;
    points2D(j1*15+1:(j1+1)*15,2)=Set2(j1+1);
end

for j2=0:3
    points3D(j2*15*8+1:(j2+1)*15*8,1:2)=points2D;
    points3D(j2*15*8+1:(j2+1)*15*8,3)=Set3(j2+1);
end

% These points defined a line, a rectangle and a cubiod respectively,
% though the same approach could be used to define any number of shapes, as
% long as the points are kept as a vector of the co-ordinate points.

% The Offgrid constructor is then called by
%

Ogrid1D=OffGrid(kgrid1D,points1D);
Ogrid2D=OffGrid(kgrid2D,points2D);
Ogrid3D=OffGrid(kgrid3D,points3D);

% The first input is the underlying grid.
% The second input are the grid locations.

% There are in addition presets for constructing the offgrid domain.
% We will now use a fixed number of Offgrid points given by Nxi
Nxi=70;
%
% In 2D the line, filled circle, arc and circle constructors can be used,
% In order to produce a line two positions must be given, these are the
% start and end point, as well as the number of points
line.startPoint=[-0.4,-0.3];
line.endPoint=[0.4,0.3];
line.points=Nxi;
% The line between these two points is then given by
OgridLine=OffGrid(kgrid2D,'line',line);
% If instead we wish to define a curve we can do so in two ways. In both
% cases the numeber of points and the radius of curvature are required
arc.radius=0.8;
arc.points=Nxi;
arc2.radius=0.8;
arc2.points=Nxi;
%Then we can either define the centre of the circle and the angles that
%define the arc (0,4 pi)
arc.centre=[-0.6,0];
arc.startAngle=15*pi/8;
arc.endAngle=17*pi/8;
% The start angle must be less than the end Angle. Note that the centre of
% the circle does not need to be in the domain, only the entire arc.
OgridArc1=OffGrid(kgrid2D,'arc',arc);
% We can alternatively provide a fixed midpoint of the arc, the distance
% between thetwo ends as the diameter, and a focus Point
arc2.midPoint=[-0.2,0];
arc2.focusPoint=[-0.1,0];
arc2.diameter=0.4;
OgridArc2=OffGrid(kgrid2D,'arc',arc2);
%The focus point is defined such that it lies on the line normal from the
%arc at the midpoint in the direction of the imagined centre of the circle.
%This dictates the orientation of the line.

% For a full circle we need only to describe the centre point and the radius
circ.centre=[0.1,0.1];
circ.radius=0.3;
circ.points=Nxi;
OgridCircle=OffGrid(kgrid2D,'circle',circ);
% In both of these example all of the grid points are evenly distributed
% along their respective shapes.
%
% To generate a filled circle this is declared exacly as before, however it
% should be considered that a larger number of points will with to be
% considered
circ.points=Nxi^2;
OgridFilledCircle=OffGrid(kgrid2D,'filledCircle',circ);
%
% To construct a parrallelagram we can use the ckey word parrallel and
% provide 3 corners. corner1, corner2 and corner3. corner1 is considered to
% have edges to corner2 and corner3 which do not connect. The number of
% points used is distributed approximately according to the the ratio of
% the lengths and perimeters
parral.corner1=[-0.4,0.3];
parral.corner2=[-0.1,-0.1];
parral.corner3=[0.1,0.1];
parral.points=Nxi*10;
OgridParrallelagram=OffGrid(kgrid2D,'parrallel',parral);
%
% To generate a circle segment, which generates a segment slice of a ring,
% the radius of curvature of the OUTSIDE
% The diameter of the outside of the ring
% The diameter of the inside of the ring
% the midPoint of the outside of the ring
% a focusPoint of the outside of the ring on the centre beam
% Suggested: midpoint of inside of the ring for focusPoints
circSegment.points=(Nxi^2) /2;
circSegment.radius=0.3;
circSegment.innerDiameter=0.2;
circSegment.outerDiameter=0.4;
circSegment.midPoint=[-0.2,0.15];
circSegment.focusPoint=[-0.1,0.075];
OgridCircleSegment=OffGrid(kgrid2D,'circleSegment',circSegment);
%
% If points are defined in more than one OffGrid object they can be merged
% calling both of the OffGrid operators
 OgridMerge=OffGrid(kgrid2D,OgridCircle,OgridLine);
% It must be ensured that all three use the same underlying grid.
%
% In 3D we can use the ball constructor, The ball constructor like the
% circle requires both the centre, the radius and the number of points. y
% values on the sphere are evenly distributed across the Nxi points with
% the x and z points in a spiral following the goldon ratio. 
sphere.centre=[0.05,-0.05,0];
sphere.radius=0.2;
sphere.points=Nxi*10;
OgridBall=OffGrid(kgrid3D,'ball',sphere);
%
% Also in 3D we can define a disk just as a filled circle in 2D now with an
% additional input options.focusPoint. the Focus point is a point along the
% unit normal from the disk at the centre, fixing the orientation of the
% disk, just as with the second implementation of the disk.
disk.centre=[0.05,-0.05,0.01];
disk.radius=0.25;
disk.focusPoint=[0.04,-0.06,0.02];
disk.points=Nxi*5;
OgridDisk=OffGrid(kgrid3D,'disk',disk);
%
% Expanding the disk, we can also describe a bowl. we now give a midPoint
% as the midPoint On the disk, the focusPoint as above, the radius of
% curvature and the diameter, equivalent to the example for arc2 in 2D.
bowl.midPoint=[0.05,-0.05,0.01];
bowl.radius=0.25;
bowl.diameter=0.4;
bowl.focusPoint=[0.04,-0.06,0.02];
bowl.points=Nxi*10;
OgridBowl=OffGrid(kgrid3D,'bowl',bowl);

bowl2.bowlPos=[-0.05,+0.05,-0.01];
bowl2.radius=0.25;
bowl2.outerDiameter=0.4;
bowl2.innerDiameter=0.2;
bowl2.focusPoint=[-0.04,0.06,-0.02];
bowl2.points=Nxi*10;
OgridsphericalSegment=OffGrid(kgrid3D,'sphericalSegment',bowl2);

% The below plots demonstrate each of the off-grid point sets, plotted
% seperately for 1D, 2D and 3D.

figure(1)
plot(Ogrid1D.kgridLocations(:,1),0,'x')
xlim([-0.5,0.5])

figure(2)
hold off
plot(Ogrid2D.kgridLocations(:,1),Ogrid2D.kgridLocations(:,2),'bx')
xlim([-0.5,0.5])
ylim([-0.5,0.5])
hold on
plot(OgridLine.kgridLocations(:,1),OgridLine.kgridLocations(:,2),'r')
plot(OgridArc1.kgridLocations(:,1),OgridArc1.kgridLocations(:,2),'m')
plot(OgridArc2.kgridLocations(:,1),OgridArc2.kgridLocations(:,2),'k')
plot(OgridCircle.kgridLocations(:,1),OgridCircle.kgridLocations(:,2),'y')
plot(OgridFilledCircle.kgridLocations(:,1),OgridFilledCircle.kgridLocations(:,2),'c+')
plot(OgridMerge.kgridLocations(:,1),OgridMerge.kgridLocations(:,2),'g*')
plot(OgridParrallelagram.kgridLocations(:,1),OgridParrallelagram.kgridLocations(:,2),'ro')
plot(OgridCircleSegment.kgridLocations(:,1),OgridCircleSegment.kgridLocations(:,2),'m.')

figure(3)
hold off
scatter3(Ogrid3D.kgridLocations(:,1),Ogrid3D.kgridLocations(:,2),Ogrid3D.kgridLocations(:,3),'b')
xlim([-0.5,0.5])
ylim([-0.5,0.5])
zlim([-0.5,0.5])
hold on
scatter3(OgridBall.kgridLocations(:,1),OgridBall.kgridLocations(:,2),OgridBall.kgridLocations(:,3),'r')
scatter3(OgridDisk.kgridLocations(:,1),OgridDisk.kgridLocations(:,2),OgridDisk.kgridLocations(:,3),'m')
scatter3(OgridBowl.kgridLocations(:,1),OgridBowl.kgridLocations(:,2),OgridBowl.kgridLocations(:,3),'k')
scatter3(OgridsphericalSegment.kgridLocations(:,1),OgridsphericalSegment.kgridLocations(:,2),OgridsphericalSegment.kgridLocations(:,3),'c')