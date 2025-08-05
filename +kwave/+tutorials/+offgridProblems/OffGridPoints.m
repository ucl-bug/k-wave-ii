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
% * 
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
% In 2D the line and circle constructors can be used,
% In order to produce a line two positions must be given, these are the
% start and end point, as well as the number of points
line.startPoint=[-0.4,-0.3];
line.endPoint=[0.4,0.3];
line.points=Nxi;
% The line between these two points is then given by
OgridLine=OffGrid(kgrid2D,'line',line);
% While for a circle we need to describe the centre point and the radius
circ.centre=[0.1,0.1];
circ.radius=0.3;
circ.points=Nxi;
OgridCircle=OffGrid(kgrid2D,'circle',circ);
% In both of these example all of the grid points are evenly distributed
% along their respective shapes.
%
% If points are defined in more than one OffGrid object they can be merged
% calling both of the OffGrid operators
 OGridMerge=OffGrid(kgrid2D,OgridCircle,OgridLine);
% It must be ensured that all three use the same underlying grid.
%
% In 3D we can use the ball constructor, The ball constructor like the
% circle requires both the centre and the radius, however it also requires
% two numbers for the points, pointsTheta, and pointsPhi. The sphere is
% parametrised by theta in [0,2pi), in the xy plane. Each disk is then
% described by the number of points options.pointsTheta. The second
% co-ordinate is phi in [-pi/2,pi/2] describes the height of the disks 
% constructing the ball with options.pointsPhi describing the number of 
% cross-sections, with a total number of boundary points given by their
% product.
% WARNING: THE DENSITY OF THE POINTS AT THE TOP AND BOTTOM COMPARED TO THE
% CENTRE HAS NOT BEEN TESTED FOR EFFECTS ON ACCURACY.
% WARNING: OTHER PARAMETRISATIONS EXIST AND MAY PROVIDE BETTER RESULTS.
sphere.centre=[0.05,-0.05,0];
sphere.radius=0.2;
sphere.pointsTheta=Nxi;
sphere.pointsPhi=Nxi;
OgridBall=OffGrid(kgrid3D,'ball',sphere);