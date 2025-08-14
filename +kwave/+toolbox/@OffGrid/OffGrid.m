%% OffGrid
% *Package:* kwave.toolbox
%
% Store points off of a spatial grid.
%
%% Syntax
% OffGrid( kgrid, kgridPoints, options )
%% Description
% The OffGrid objects are for the implementation and use of shapes that do
% not adhear to the gridpoints, equipped with the bandlimited interpolation
% functions allowing for interaction with the grid.
% When constructing a set of offgrid points these points can either be fed
% to the constructor as a vector of the vector co-ordinates according to
% the grid space, or by utilising a contrustion key word and providing the
% equivalent option terms. Additionally any two OffGrid  onbjects on the 
% same domain can be merged by calling a constuctor with the grid, and both
% OffGrid objects to be included.
%
%% Input Arguments
%
% kgrid = kwave.toolbox.Grid
% kgridPoints = numerical Array of size [Nxi, dim], where Nxi is the number
% of offFGrid points to be given and dim is the dimension of the space.
% Each row kgridPoints(n,:) is a vector contained within the Grid.
%
% kgridPoints =  String. A number of preset domains are included and called
% by the appropriate string with options.parameters.
% For a 2D grid. kgridPoints can take the names
%   "line"          requires options.points, option.startPoint, option.endPoint
%   "arc"           requires options.points, options.radius,options.diameter,
%                               options.midPoint, options. focusPoint
%                   OR       options.points, options.radius, options.centre,
%                               options.startAngle, options.endAngle
%   "circle"        requires options.points, options.centre, options.radius
%   "filledCircle"  requires options.points, options.centre, options.radius
%   "parrallel"     requires options.points, options.corner1, options.corner2,
%                               options.corner3
% 
% For a 3D grid. kgridPoints can take the names
%   "ball"          requires options.points, options.centre, options.radius
%   "disk"          requires options.points, options.centre, options.radius, 
%                               options.focusPoint
%   "bowl"          requires options.points, options.midPoint, options.radius, 
%                               options.focusPoint, options.diameter
%
% For any two offGrid domain the grid can be merged by providing the first
% OffGrid object as kgridValues and the second as the options input. The
% result will use all points contained in both, removing any repetitions.
% In this way inductively any number of offGrid domains can be merged.
% kgridPoints = kwave.toolbox.OffGrid, options = kwave.toolbox.OffGrid
%% Properties
%   kgrid
%   gridSize
%   kgridLocations
%   gridLocations        
%   xLoc;
%   yLoc;
%   zLoc;
%
%% Methods
%   obj.ValidGridpointDistance(x1,x2,accuracy)
%   obj.BandLimGridCoOdd(x1,x2,dim)
%   obj.BandLimCoOdd(x1,x2,dim)
%   obj.BandLimGridCoEven(x1,x2,dim)
%   obj.BandLimCoEven(x1,x2,dim)
%   obj.BandLimeGrid(x1,x2,accuracy)
%   obj.BandLim(x1,x2)
%   obj.InvBandLimMatrix()
%% Example
% kgrid = Grid([10, 10, 10], 1e-3);
% Nx=10;
% Ny=15;
% rad=0.003;
% Locs=zeros(Nxi,Nyi,3);
% Locs(:,:,1)=cos(0:2*pi/(Nx-1):2*pi).'.*(cos(-pi/2:pi/(Ny-1):pi/2));
% Locs(:,:,2)=sin(0:2*pi/(Nx-1):2*pi).'.*(cos(-pi/2:pi/(Ny-1):pi/2));
% Locs(:,:,3)=Locs(:,:,3)+(sin(-pi/2:pi/(Ny-1):pi/2));
% Locs=Locs.*rad;
% OffGridBall=OffGrid(kgrid,Locs);
%
% ball.radius=0.003;
% ball.centre=[0,0,0];
% OffGridBall2=OffGrid(kgrid,[Nx,Ny],'ball',ball);
%
% Copyright (C) 2025- The k-Wave Authors.
%
% This file is part of k-Wave-II (http://www.k-wave.org). k-Wave-II is free
% software: you can redistribute it and/or modify it under the terms of the
% GNU Lesser General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any
% later version.
%
% k-Wave-II is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
% License for more details.
%
% You should have received a copy of the GNU Lesser General Public License
% along with k-Wave-II. If not, see <http://www.gnu.org/licenses/>.
%
classdef OffGrid < handle

    % Properties set by constructor.
    properties(SetAccess=immutable)

        %
        kgrid kwave.toolbox.Grid
        % Grid size [grid points].
        gridSize(1,1) double {mustBeInteger, mustBePositive, mustBeFinite} = [1];
        % Locations of the Points
        kgridLocations = [];
    end
    properties
    gridLocations = [];
    end

    % Dependent properties without set methods. These parameters are not
    % stored but re-computed each time they are needed.
    properties(Dependent=true, GetAccess=public, SetAccess=private)
        % Nx,Ny,Nz vectors containing copies of the grid
        % coordinates for each point [m].
        xLoc;
        yLoc;
        zLoc;
    end

    % Constructor.
    methods
        function obj = OffGrid(kgrid, kgridLocations,options)

            obj.kgrid = kgrid;

            if isnumeric(kgridLocations)
                    [A,B]=size(kgridLocations); 
                    if B~=kgrid.dimensions && A==kgrid.dimensions
                        kgridLocations=kgridLocations.';
                        [~,B]=size(kgridLocations); 
                    end
                    assert(B==kgrid.dimensions);
                    obj.kgridLocations=kgridLocations;
                switch obj.kgrid.dimensions
                    case 1
                        assert(max(abs(obj.xLoc))<obj.kgrid.xSize/2)
                    case 2
                        assert(max(abs(obj.yLoc))<obj.kgrid.ySize/2)
                        assert(max(abs(obj.xLoc))<obj.kgrid.xSize/2)
                    case 3
                        assert(max(abs(obj.yLoc))<obj.kgrid.ySize/2)
                        assert(max(abs(obj.xLoc))<obj.kgrid.xSize/2)
                        assert(max(abs(obj.zLoc))<obj.kgrid.zSize/2)
                end

            elseif ischar(kgridLocations)

                if strcmp(kgridLocations,'ball')
                    % Ball requires a centre point and a radius
                    assert( ~isempty(options.radius), ~isempty(options.centre), ~isempty(options.points))
                    assert( obj.kgrid.dimensions==3)

                    ratio = pi * (3 - sqrt(5));
                    off = 2 / options.points;
                    k = 0:options.points-1;
                    y = k * off - 1 + (off/2); %equal spaced heights
                    r = sqrt(1 - (y.^2)); %radial ratio for the circle x,z (x^2 + z^2= r^2 = 1-y^2)
                    phi = k * ratio;

                    kgridLocations=zeros(options.points,3);
                    kgridLocations(:,1)=options.centre(1)+options.radius .* cos(phi) .* r;
                    kgridLocations(:,2)=options.centre(2)+options.radius*y;
                    kgridLocations(:,3)=options.centre(3)+options.radius .* sin(phi) .* r;
                    
                    obj.kgridLocations=kgridLocations;
                    assert(max(abs(obj.xLoc))<obj.kgrid.xSize/2)
                    assert(max(abs(obj.yLoc))<obj.kgrid.ySize/2)
                    assert(max(abs(obj.zLoc))<obj.kgrid.zSize/2)

                elseif strcmp(kgridLocations,'disk')
                    % Disk requires a centre point, a radius and a tangent
                    % vector

                    assert( ~isempty(options.radius), ~isempty(options.centre), ~isempty(options.points), ~isempty(options.focusPoint))
                    assert( obj.kgrid.dimensions==3)

                    Nxi=options.points;
                    kgridLocations=zeros(Nxi,3);
                    
                    Parametrisation = 0:1:Nxi-1;

                    ratio = pi * (3 - sqrt(5));

                    angle = @(t) ratio.*t;

                    radial = @(t) sqrt( options.radius^2 .* t / (Nxi-1) );
                    planex=radial(Parametrisation).*cos(angle(Parametrisation));
                    planey=radial(Parametrisation).*sin(angle(Parametrisation));

                    n=(options.focusPoint - options.centre)/norm((options.focusPoint - options.centre));
                    ni=sqrt( 1- n(3)^2);
                    
                    kgridLocations(:,1)=options.centre(1)-n(1)*n(3)*planey/ni +n(2)*planex/ni;
                    kgridLocations(:,2)=options.centre(2)-n(2)*n(3)*planey/ni -n(1)*planex/ni;
                    kgridLocations(:,3)=options.centre(3)+ni*planey;

                    obj.kgridLocations=kgridLocations;
                    assert(max(abs(obj.xLoc))<obj.kgrid.xSize/2)
                    assert(max(abs(obj.yLoc))<obj.kgrid.ySize/2)
                    assert(max(abs(obj.zLoc))<obj.kgrid.zSize/2)

                elseif strcmp(kgridLocations,'bowl')
                    % The bowl takes midPoint, focusPoint, diameter, radius and points

                    assert( ~isempty(options.radius), ~isempty(options.midPoint), ~isempty(options.points), ~isempty(options.focusPoint))
                    assert( obj.kgrid.dimensions==3)

                     ratio = pi * (3 - sqrt(5));

                    %Angle from base
                    maxAngle=acos( options.diameter/ (2*options.radius));
                    anglesZ=linspace(-pi/2, maxAngle,options.points);
                    anglesXY=ratio*(0:1:options.points-1);

                    %Unit bowl under the origin, midpoint=[0,0,-1]
                    bowlx=cos(anglesXY) .* sin(anglesZ);
                    bowly=sin(anglesXY) .* sin(anglesZ);
                    bowlz=cos(anglesZ);
                    
                    % normal vector { roatated to from (0,0,1) }
                    n=(options.focusPoint - options.midPoint)/norm((options.focusPoint - options.midPoint));
                    ni=sqrt( 1- n(3)^2);
                    kgridLocations=zeros(options.points,3);
                    % applies rotation matricies
                    if abs(n(3))~=1
                        kgridLocations(:,1)=options.midPoint(1)+options.radius*n(1)+options.radius*(n(2)*bowlx/ni -n(1)*n(3)*bowly/ni - n(1)*bowlz);
                        kgridLocations(:,2)=options.midPoint(2)+options.radius*n(2)+options.radius*(-n(1)*bowlx/ni -n(2)*n(3)*bowly/ni - n(2)*bowlz);
                        kgridLocations(:,3)=options.midPoint(3)+options.radius*n(3)+options.radius*(ni*bowly - n(3)*bowlz);
                    elseif n(3)==1
                        kgridLocations(:,1)=options.midPoint(1)+options.radius*(bowly);
                        kgridLocations(:,2)=options.midPoint(2)+options.radius*(bowlx);
                        kgridLocations(:,3)=options.midPoint(3)+options.radius+options.radius*(n(3)*bowlz);
                    elseif n(3)==-1
                            kgridLocations(:,1)=options.midPoint(1)-options.radius*bowlx;
                        kgridLocations(:,2)=options.midPoint(2)-options.radius*bowly;
                        kgridLocations(:,3)=options.midPoint(3)-options.radius-options.radius*bowlz;
                    end
                    obj.kgridLocations=kgridLocations;
                    assert(max(abs(obj.xLoc))<obj.kgrid.xSize/2)
                    assert(max(abs(obj.yLoc))<obj.kgrid.ySize/2)
                    assert(max(abs(obj.zLoc))<obj.kgrid.zSize/2)
                   
                elseif strcmp(kgridLocations,'filledCircle')
                    % Circles require a centre point and a radius, must be
                    % in 2D
                    assert( ~isempty(options.radius), ~isempty(options.centre), ~isempty(options.points))
                    assert( obj.kgrid.dimensions==2)

                    Nxi=options.points;
                    kgridLocations=zeros(Nxi,2);
                    
                    Parametrisation = 0:1:Nxi-1;

                    GOLDEN_ANGLE = 2.39996322972865332223155550663361385312499901105811504;

                    angle = @(t) GOLDEN_ANGLE.*t;

                    radial = @(t) sqrt( options.radius^2 .* t / (Nxi-1) );

                    kgridLocations(:,1)=options.centre(1)+radial(Parametrisation).*cos(angle(Parametrisation));
                    kgridLocations(:,2)=options.centre(2)+radial(Parametrisation).*sin(angle(Parametrisation));

                    obj.kgridLocations=kgridLocations;
                    assert(max(abs(obj.xLoc))<obj.kgrid.xSize/2)
                    assert(max(abs(obj.yLoc))<obj.kgrid.ySize/2)

                 elseif strcmp(kgridLocations,'circleSegment')
                    % Circle segment, requires the inner and outer
                    % diameter the outer centre point, a focus point
                    % (recommended mid inner point) the radius of curvature
                    % for the outer arc and the number of points.

                    assert( ~isempty(options.radius), ~isempty(options.midPoint),~isempty(options.focusPoint), ~isempty(options.points), ~isempty(options.innerDiameter), ~isempty(options.outerDiameter))
                    assert( obj.kgrid.dimensions==2)

                    Nxi=options.points;
                    kgridLocations=zeros(Nxi,2);
                    
                    Parametrisation = 0:1:Nxi-1;

                    GOLDEN_ANGLE =  pi * (3 - sqrt(5));
                    MaxAngle = asin( options.outerDiameter / (2*options.radius));
                    radInt=options.radius*options.innerDiameter/options.outerDiameter;

                    angle = @(t) mod(GOLDEN_ANGLE.*t,2*MaxAngle) - MaxAngle;

                    radial = @(t) options.radius + (( 1- t / (Nxi-1) ).^2) .* (radInt - options.radius);

                    n=(options.midPoint-options.focusPoint)/norm(options.midPoint-options.focusPoint);
                    %n=[-1,0];
                    circlesegx= radial(Parametrisation).'.*cos(angle(Parametrisation)).'-options.radius;
                    circlesegy= radial(Parametrisation).'.*sin(angle(Parametrisation)).';
                        
                    kgridLocations(:,1)=options.midPoint(1)+n(1)*circlesegx-n(2)*circlesegy;
                    kgridLocations(:,2)=options.midPoint(2)+n(2)*circlesegx+n(1)*circlesegy;


                    obj.kgridLocations=kgridLocations;
                    assert(max(abs(obj.xLoc))<obj.kgrid.xSize/2)
                    assert(max(abs(obj.yLoc))<obj.kgrid.ySize/2)


                elseif strcmp(kgridLocations,'circle')
                    % Circles require a centre point and a radius, must be
                    % in 2D
                    assert( ~isempty(options.radius), ~isempty(options.centre), ~isempty(options.points))
                    assert( obj.kgrid.dimensions==2)

                    Nxi=options.points;
                    kgridLocations=zeros(Nxi,2);
                    
                    kgridLocations(:,1)=options.centre(1)+options.radius.*cos((-pi:2*pi/(Nxi):pi*(Nxi-1)/Nxi) );
                    kgridLocations(:,2)=options.centre(2)+options.radius.*sin((-pi:2*pi/(Nxi):pi*(Nxi-1)/Nxi) );

                    obj.kgridLocations=kgridLocations;
                    assert(max(abs(obj.xLoc))<obj.kgrid.xSize/2)
                    assert(max(abs(obj.yLoc))<obj.kgrid.ySize/2)

                elseif strcmp(kgridLocations,'parrallel')
                    % Constructs a parrallelagram based on three corners
                    % given with edges between (corner1 and corner2) asnd
                    % (corner1 and corner3)
                    assert( ~isempty(options.corner1), ~isempty(options.corner2), ~isempty(options.corner3), ~isempty(options.points))
                    assert( obj.kgrid.dimensions==2)
                    assert(all(size(options.corner1)==[1,2]));
                    assert(all(size(options.corner2)==[1,2]));
                    assert(all(size(options.corner3)==[1,2]));
                    assert(max(options.corner1~=options.corner2)==1 && max(options.corner1~=options.corner3)==1 && max(options.corner2~=options.corner3)==1);
                    HalfPerim=norm(options.corner1-options.corner2) + norm(options.corner1-options.corner3);
                    
                    Nxi=options.points;
                    Nxy=ceil(norm(options.corner1-options.corner2)*Nxi/(2*HalfPerim));
                    Nxz=ceil(Nxi/2 -Nxy);
                    Nxyz=Nxi-2*Nxy-Nxz;
                    corner4=options.corner2+options.corner3-options.corner1;

                    locs=[linspace(options.corner1(1),options.corner2(1),Nxy+1).',linspace(options.corner1(2),options.corner2(2),Nxy+1).' ; ...
                      linspace(options.corner2(1),corner4(1),Nxyz+1).',linspace(options.corner2(2),corner4(2),Nxyz+1).' ;  ...
                      linspace(corner4(1),options.corner3(1),Nxy+1).',linspace(corner4(2),options.corner3(2),Nxy+1).' ;  ...
                      linspace(options.corner3(1),options.corner1(1),Nxz+1).',linspace(options.corner3(2),options.corner1(2),Nxz+1).'];
                    
                    obj.kgridLocations=unique(locs,"rows");
                    assert(length(obj.kgridLocations(:,1))==Nxi)

                    assert(max(abs(obj.xLoc))<obj.kgrid.xSize/2)
                    assert(max(abs(obj.yLoc))<obj.kgrid.ySize/2)

                elseif strcmp(kgridLocations,'line')
                    % Lines need to be in 2D and be given a 2D start and End Point 
                    assert( ~isempty(options.startPoint), ~isempty(options.endPoint), ~isempty(options.points))
                    assert(all(size(options.startPoint)==[1,2]));
                    assert(all(size(options.endPoint)==[1,2]));
                    assert( obj.kgrid.dimensions==2)

                    Nxi=options.points;
                    kgridLocations=zeros(Nxi,2);

                    kgridLocations(:,1)=((0.5:1:Nxi-0.5))*options.startPoint(1)/Nxi + ( 1- ((0.5:1:Nxi-0.5)/Nxi))*options.endPoint(1);
                    kgridLocations(:,2)=((0.5:1:Nxi-0.5))*options.startPoint(2)/Nxi + ( 1- ((0.5:1:Nxi-0.5)/Nxi))*options.endPoint(2);

                    obj.kgridLocations=kgridLocations;
                    assert(max(abs(obj.xLoc))<obj.kgrid.xSize/2)
                    assert(max(abs(obj.yLoc))<obj.kgrid.ySize/2)

                elseif strcmp(kgridLocations,'arc')
                    
                    assert( ~isempty(options.radius), ~isempty(options.points),(obj.kgrid.dimensions==2))
                    if isfield(options,'centre')
                        assert(~isempty(options.startAngle),~isempty(options.endAngle))
                        assert( options.startAngle<4*pi, options.startAngle>0, options.endAngle>0, options.startAngle<options.endAngle)
                        N=options.points;
                        angles= ((N-1)*options.startAngle + options.endAngle )/ N: (options.endAngle-options.startAngle)/(N+2) :((N-1)*options.endAngle + options.startAngle )/ N;
                        kgridLocations=zeros(N,2);

                        kgridLocations(:,1)=options.centre(1)+options.radius.*cos(angles ).';
                        kgridLocations(:,2)=options.centre(2)+options.radius.*sin(angles ).';
                        obj.kgridLocations=kgridLocations;
                        assert(max(abs(obj.xLoc))<obj.kgrid.xSize/2)
                        assert(max(abs(obj.yLoc))<obj.kgrid.ySize/2)

                    elseif isfield(options,'diameter')
                        assert( ~isempty(options.midPoint),~isempty(options.focusPoint))
                        varphi_max = asin(options.diameter ./ (2 * options.radius));
                        dvarphi = 2 * varphi_max ./ options.points;
                        t = linspace(-varphi_max + dvarphi/2, varphi_max - dvarphi/2, options.points);

         
                        n=(options.midPoint-options.focusPoint)/norm(options.midPoint-options.focusPoint);
                        circlesegx= options.radius.*cos(t).'-options.radius;
                        circlesegy= options.radius.*sin(t).';
                        
                        kgridLocations=zeros(options.points,2);
                        kgridLocations(:,1)=options.midPoint(1)+n(1)*circlesegx-n(2)*circlesegy;
                        kgridLocations(:,2)=options.midPoint(2)+n(2)*circlesegx+n(1)*circlesegy;
                        obj.kgridLocations=kgridLocations;
                        assert(max(abs(obj.xLoc))<obj.kgrid.xSize/2)
                        assert(max(abs(obj.yLoc))<obj.kgrid.ySize/2)
                    else
                        error("Method requires either the centre point or the diameter to define the arc.")
                    end

                    % elseif strcmP(kgridLocations, 'NAME')
                    % % For use to build new examples
                    % % Assert required parameters as options.SUBNAME
                    % % Assert that the required additional parameters are of
                    % the correct form.
                    % % Asser that the grid has the correct dimensions
                    % %
                    % % Define the points
                    %    Nxi=gridSize;
                    %    kgridLocations=zeros(Nxi,obj.kgrid.dimensions);
                    % %
                    % %
                    % %
                    % Assign to the object
                    %    obj.kgridLocations=kgridLocations;
                    % Make sure that the maximum locations are all within the grid.
                    %    assert(max(abs(obj.xLoc))<obj.kgrid.xSize/2)
                    %    assert(max(abs(obj.yLoc))<obj.kgrid.ySize/2) % etc

                    % ADd instructions to the Summary.

                end

            elseif isa(kgridLocations,'kwave.toolbox.OffGrid')
                assert(isa(options,'kwave.toolbox.OffGrid'))
                assert( obj.kgrid == kgridLocations.kgrid && obj.kgrid== options.kgrid )

                kgridLocations=[kgridLocations.kgridLocations; options.kgridLocations];
                obj.kgridLocations=unique(kgridLocations,'rows');

            end

            obj.gridSize=length(obj.kgridLocations(:,1));
            obj.gridLocations=obj.kgridLocations;
            switch obj.kgrid.dimensions
                case 1
                    obj.gridLocations(:,1)=obj.kgridLocations(:,1)/kgrid.gridSpacing(1);
                case 2
                    obj.gridLocations(:,1)=obj.kgridLocations(:,1)/kgrid.gridSpacing(1);
                    obj.gridLocations(:,2)=obj.kgridLocations(:,2)/kgrid.gridSpacing(2);
                case 3
                    obj.gridLocations(:,1)=obj.kgridLocations(:,1)/kgrid.gridSpacing(1);
                    obj.gridLocations(:,2)=obj.kgridLocations(:,2)/kgrid.gridSpacing(2);
                    obj.gridLocations(:,3)=obj.kgridLocations(:,3)/kgrid.gridSpacing(3);
            end

        end

    end

    % Get methods for dependent properties.
    methods

        function xLoc = get.xLoc(obj)
            xLoc = obj.kgridLocations(:,1);
        end

        function yLoc = get.yLoc(obj)
            yLoc = obj.kgridLocations(:,2);
        end

        function zLoc = get.zLoc(obj)
            zLoc = obj.kgridLocations(:,3);
        end

    end

    methods

        function Val=ValidGridpointDistance(obj,x1,x2,accuracy)
            % x1, x2 should be prescaled by 1/dx.
            x1=x1.';
            m=ceil(1/(pi*accuracy));
            Val=zeros(length(x2(:,1)),length(x1(1,:)));
            dist=zeros(length(x2(:,1)),length(x1(1,:)));
            for dim=1:obj.kgrid.dimensions
                dist=dist+floor(abs(x1(dim,:)-x2(:,dim)));
            end
                        Val(dist<=m)=1;
        end

        % Odd sized Grid
        function BandLimPointCoOdd=BandLimCoOdd(obj,x1,x2,n)
            x1=x1.';
            v=pi*(x1-x2);
            BandLimPointCoOdd = sin(v) ./ ( obj.kgrid.gridSize(n) * sin (v/( obj.kgrid.gridSize(n))) );
            BandLimPointCoOdd(isnan(BandLimPointCoOdd))=1;
        end
        
        % Even sized Grid with one vector on the grid
        function BandLimGridPointCoEven=BandLimGridCoEven(obj,x1,x2,n)
            x1=x1.';
            v=pi*(x1-x2);
            BandLimGridPointCoEven = sin(v) ./ ( obj.kgrid.gridSize(n) * tan (v/( obj.kgrid.gridSize(n))) );
            BandLimGridPointCoEven(isnan(BandLimGridPointCoEven))=1;
        end

        % General Even sized Grid
        function BandLimPointCoEven=BandLimCoEven(obj,x1,x2,n)
            x1=x1.';
            v=pi*(x1-x2);
            BandLimPointCoEven = sin(v) ./ ( obj.kgrid.gridSize(n) * tan (v/( obj.kgrid.gridSize(n))) );
            BandLimPointCoEven(isnan(BandLimPointCoEven ))=1;
            BandLimPointCoEven = BandLimPointCoEven - sin(pi*(x1)).*sin(pi*(x2))/( obj.kgrid.gridSize(n))  ...
                + 1i* sin(pi*(x1)).*cos(pi*(x2))/( obj.kgrid.gridSize(n));
        end

        % Formulation for using an on grid vector
        function BandLimGridPoint=BandLimGrid(obj,x1,x2,accuracy)
            BandLimGridPoint=1;
            for dim=1:obj.kgrid.dimensions
                if obj.kgrid.gridSize(dim)/2==ceil(obj.kgrid.gridSize(dim)/2)
                    BandLimGridPoint=BandLimGridPoint.*BandLimGridCoEven(obj,x1(:,dim),x2(:,dim),dim);
                else
                    BandLimGridPoint=BandLimGridPoint.*BandLimCoOdd(obj,x1(:,dim),x2(:,dim),dim);
                end
            end
            BandLimGridPoint=ValidGridpointDistance(obj,x1,x2,accuracy).*BandLimGridPoint;
        end

        
        % Matrix for rescaling boundaries.
        function BandLimPoint=BandLim(obj,x1,x2)
            BandLimPoint=1;
            for dim=1:obj.kgrid.dimensions
                if obj.kgrid.gridSize(dim)/2==ceil(obj.kgrid.gridSize(dim)/2)
                    BandLimPoint=BandLimPoint.*BandLimCoEven(obj,x1(:,dim),x2(:,dim),dim);
                else
                    BandLimPoint=BandLimPoint.*BandLimCoOdd(obj,x1(:,dim),x2(:,dim),dim);
                end
            end
        end

        % Inverse Matrix
        function InvBandLimMatrix=InvBandLimMatrix(obj)
            BandLimMatrix= obj.BandLim(obj.gridLocations,obj.gridLocations);
            InvBandLimMatrix=inv(BandLimMatrix);
        end


    end

end
