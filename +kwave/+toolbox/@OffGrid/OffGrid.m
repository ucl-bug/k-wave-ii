%% OffGrid
% *Package:* kwave.toolbox
%
% Summary
%
%% Syntax
%
%% Description
%
%% Input Arguments
%
%% Properties
%
%% Methods
%
%% Writing Notes,
% Everything that happens should be invariant up to Nx X Ny constant.
% Inputs are kgrid, Nx, Ny, GridLocations
% Grid Locations needs to be an Nx x Ny x kgrid.dimensions array
% when I reffer to the grid Nx and Ny I need to write kgrid.Nx and kgrid.Ny
% (:,:,1) are the x co-ordinates wrt the grid must be given
% (:,:,2) are the y co-ordinates wrt the grid if given
% (:,:,3) are the z co-ordinates wrt the grid if given
%
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
% OffGridBall=OffGrid(kgrid,[Nx,Ny],Locs);
%
% ball.radius=0.003;
% ball.centre=[0,0,0];
% OffGridBall2=OffGrid(kgrid,[Nx,Ny],'ball',ball);
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

    normalVector=[];
    
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

    properties(Hidden, Dependent=true, SetAccess=private)

        % InvBandLimMatrix

        % BandLimGrid

        % Distaces
    end

    % Constructor.
    methods
        function obj = OffGrid(kgrid, kgridLocations,options)

            obj.kgrid = kgrid;

            if isnumeric(kgridLocations)
                    [A,B]=size(kgridLocations); 
                    if B~=kgrid.dimensions && A==kgrid.dimensions
                        kgridLocations=kgridLocations.';
                        [A,B]=size(kgridLocations); 
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
                    assert( ~isempty(options.radius), ~isempty(options.centre), ~isempty(options.pointsTheta), ~isempty(options.pointsPhi))
                    assert( obj.kgrid.dimensions==3)

                    Nxi=options.pointsTheta;
                    Nyi=options.pointsPhi;
                    kgridLocations=zeros(Nxi,Nyi,3);

                    kgridLocations(:,:,1)=options.centre(1)+cos(0:2*pi/(Nxi-1):2*pi).'.*(cos(-pi/2:pi/(Nyi-1):pi/2));
                    kgridLocations(:,:,2)=options.centre(2)+sin(0:2*pi/(Nxi-1):2*pi).'.*(cos(-pi/2:pi/(Nyi-1):pi/2));
                    kgridLocations(:,:,3)=options.centre(3)+kgridLocations(:,:,3)+(sin(-pi/2:pi/(Nyi-1):pi/2));

                    kgridLocations=kgridLocations.*options.radius;
                    obj.kgridLocations = reshape(kgridLocations,[Nxi*Nyi,obj.kgrid.dimensions]);

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

                    GOLDEN_ANGLE = 2.39996322972865332223155550663361385312499901105811504;

                    angle = @(t) GOLDEN_ANGLE.*t;

                    radial = @(t) sqrt( options.radius^2 .* t / (Nxi-1) );
                    planex=radial(Parametrisation).*cos(angle(Parametrisation));
                    planey=radial(Parametrisation).*sin(angle(Parametrisation));

                    n=(options.focusPoint - options.centre)/norm((options.focusPoint - options.centre));
                    ni=sqrt( 1- n(3)^2);
                    
                    kgridLocations(:,1)=options.centre(1)+n(1)*n(3)*planex/ni -n(2)*planey/ni;
                    kgridLocations(:,2)=options.centre(2)+n(2)*n(3)*planex/ni -n(1)*planey/ni;
                    kgridLocations(:,3)=options.centre(3)+ni*planex;

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


                elseif strcmp(kgridLocations,'circle')
                    % Circles require a centre point and a radius, must be
                    % in 2D
                    assert( ~isempty(options.radius), ~isempty(options.centre), ~isempty(options.points))
                    assert( obj.kgrid.dimensions==2)

                    Nxi=options.points;
                    kgridLocations=zeros(Nxi,2);
                    obj.normalVector=zeros(Nxi,2);
                    
                    kgridLocations(:,1)=options.centre(1)+options.radius.*cos((-pi:2*pi/(Nxi):pi*(Nxi-1)/Nxi) );
                    kgridLocations(:,2)=options.centre(2)+options.radius.*sin((-pi:2*pi/(Nxi):pi*(Nxi-1)/Nxi) );

                    obj.normalVector(:,1)=cos((-pi:2*pi/(Nxi):pi*(Nxi-1)/Nxi) );
                    obj.normalVector(:,2)=sin((-pi:2*pi/(Nxi):pi*(Nxi-1)/Nxi) );

                    obj.kgridLocations=kgridLocations;
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
                        assert( options.startAngle<2*pi, options.startAngle>0, options.endAngle>0, options.startAngle<options.endAngle)
                        N=options.points;
                        angles= ((N-1)*options.startAngle + options.endAngle )/ N: (options.endAngle-options.startAngle)/(N+2) :((N-1)*options.endAngle + options.startAngle )/ N;
                        kgridLocations=zeros(N,2);

                        kgridLocations(:,1)=options.centre(1)+options.radius.*cos(angles ).';
                        kgridLocations(:,2)=options.centre(2)+options.radius.*sin(angles ).';
                        obj.kgridLocations=kgridLocations;
                        assert(max(abs(obj.xLoc))<obj.kgrid.xSize/2)
                        assert(max(abs(obj.yLoc))<obj.kgrid.ySize/2)

                    elseif isfield(options,'diameter')
                        assert( ~isempty(options.midpoint),~isempty(options.focusPosition))
                        varphi_max = asin(options.diameter ./ (2 * options.radius));
                        dvarphi = 2 * varphi_max ./ options.points;
                        t = linspace(-varphi_max + dvarphi/2, varphi_max - dvarphi/2, options.points);

                        centre= options.midpoint - (options.midpoint-options.focusPosition)*options.radius/abs(options.midpoint-options.focusPosition) ;
                        
                        kgridLocations=zeros(options.points,2);
                        kgridLocations(:,1)=centre(1)+options.radius.*cos(t ).';
                        kgridLocations(:,2)=centre(2)+options.radius.*sin(t ).';
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
