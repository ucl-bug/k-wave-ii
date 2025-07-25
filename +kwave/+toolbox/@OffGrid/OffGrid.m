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
        function obj = OffGrid(kgrid, gridSize, kgridLocations,options)

            obj.kgrid = kgrid;
            obj.gridSize=prod(gridSize);

            if isnumeric(kgridLocations)
                %           assert(size(kgridLocations)==[obj.gridSize,obj.kgrid.dimensions] || size(kgridLocations)==[prod(obj.gridSize),obj.kgrid.dimensions])
                obj.kgridLocations = reshape(kgridLocations,[prod(obj.gridSize),obj.kgrid.dimensions]);
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
                    assert( ~isempty(options.radius), ~isempty(options.centre))
                    assert( obj.kgrid.dimensions==3)
                    assert( min(size(gridSize)==[1,2]) )

                    Nxi=gridSize(1);
                    Nyi=gridSize(2);
                    kgridLocations=zeros(Nxi,Nyi,3);

                    kgridLocations(:,:,1)=options.centre(1)+cos(0:2*pi/(Nxi-1):2*pi).'.*(cos(-pi/2:pi/(Nyi-1):pi/2));
                    kgridLocations(:,:,2)=options.centre(2)+sin(0:2*pi/(Nxi-1):2*pi).'.*(cos(-pi/2:pi/(Nyi-1):pi/2));
                    kgridLocations(:,:,3)=options.centre(3)+kgridLocations(:,:,3)+(sin(-pi/2:pi/(Nyi-1):pi/2));

                    kgridLocations=kgridLocations.*options.radius;
                    obj.kgridLocations = reshape(kgridLocations,[prod(obj.gridSize),obj.kgrid.dimensions]);

                    assert(max(abs(obj.xLoc))<obj.kgrid.xSize/2)
                    assert(max(abs(obj.yLoc))<obj.kgrid.ySize/2)
                    assert(max(abs(obj.zLoc))<obj.kgrid.zSize/2)

                elseif strcmp(kgridLocations,'circle')
                    assert( ~isempty(options.radius), ~isempty(options.centre))
                    assert( obj.kgrid.dimensions==2)
                    assert( min(size(gridSize)==[1,1]) )

                    Nxi=gridSize;
                    kgridLocations=zeros(Nxi,2);
                    obj.normalVector=zeros(Nxi,2);
                    
                    Offset= pi*rand(1,1);
                    kgridLocations(:,1)=options.centre(1)+options.radius.*cos((-pi:2*pi/(Nxi):pi*(Nxi-1)/Nxi) );
                    kgridLocations(:,2)=options.centre(2)+options.radius.*sin((-pi:2*pi/(Nxi):pi*(Nxi-1)/Nxi) );

                    obj.normalVector(:,1)=cos((-pi:2*pi/(Nxi):pi*(Nxi-1)/Nxi) );
                    obj.normalVector(:,2)=sin((-pi:2*pi/(Nxi):pi*(Nxi-1)/Nxi) );

                    obj.kgridLocations=kgridLocations;
                    assert(max(abs(obj.xLoc))<obj.kgrid.xSize/2)
                    assert(max(abs(obj.yLoc))<obj.kgrid.ySize/2)

                elseif strcmp(kgridLocations,'line')
                    assert( ~isempty(options.startPoint), ~isempty(options.endPoint))
                    assert(min(size(options.startPoint)==[1,2]));
                    assert(min(size(options.endPoint)==[1,2]));
                    assert( obj.kgrid.dimensions==2)
                    assert( min(size(gridSize)==[1,1]) )

                    Nxi=gridSize;
                    kgridLocations=zeros(Nxi,2);

                    kgridLocations(:,1)=((0.5:1:Nxi-0.5))*options.startPoint(1)/Nxi + ( 1- ((0.5:1:Nxi-0.5)/Nxi))*options.endPoint(1);
                    kgridLocations(:,2)=((0.5:1:Nxi-0.5))*options.startPoint(2)/Nxi + ( 1- ((0.5:1:Nxi-0.5)/Nxi))*options.endPoint(2);

                    obj.kgridLocations=kgridLocations;
                    assert(max(abs(obj.xLoc))<obj.kgrid.xSize/2)
                    assert(max(abs(obj.yLoc))<obj.kgrid.ySize/2)

                end


            end
            
            
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
            x1=x1.';
            m=ceil(1/(pi*accuracy));
            % m=ceil(1/(pi*accuracy))^2;
            Val=zeros(length(x2(:,1)),length(x1(1,:)));
            dist=zeros(length(x2(:,1)),length(x1(1,:)));

            for dim=1:obj.kgrid.dimensions
                % dist=dist+floor(abs(x1(dim,:)-x2(:,dim)));
                dist=dist+(abs(x1(dim,:)-x2(:,dim))).^2;
            end
            
            % Val=zeros(length(x2(:,1)),length(x1(:,1)));
            % dist=sum(floor(abs(reshape(x2,[length(x2),1,obj.kgrid.dimensions]) - reshape(x1,[1,length(x1),obj.kgrid.dimensions]))),3);

            Val(dist<=m)=1;
        end

        function BandLimPointCoOdd=BandLimCoOdd(obj,x1,x2,n)
            x1=x1.';
            v=pi*(x1-x2);
            BandLimPointCoOdd = sin(v) ./ ( obj.kgrid.gridSize(n) * sin (v/( obj.kgrid.gridSize(n))) );
            BandLimPointCoOdd(isnan(BandLimPointCoOdd))=1;
        end

        function BandLimGridPointCoEven=BandLimGridCoEven(obj,x1,x2,n)
            x1=x1.';
            v=pi*(x1-x2);
            BandLimGridPointCoEven = sin(v) ./ ( obj.kgrid.gridSize(n) * tan (v/( obj.kgrid.gridSize(n))) );
            BandLimGridPointCoEven(isnan(BandLimGridPointCoEven))=1;
        end

        function BandLimPointCoEven=BandLimCoEven(obj,x1,x2,n)
            x1=x1.';
            v=pi*(x1-x2);
            BandLimPointCoEven = sin(v) ./ ( obj.kgrid.gridSize(n) * tan (v/( obj.kgrid.gridSize(n))) );
            BandLimPointCoEven(isnan(BandLimPointCoEven ))=1;
            %BandLimPointCoEven = BandLimPointCoEven - sin(pi*(x1)).*sin(pi*(x2))/( obj.kgrid.gridSize(n))  ...
            %    + 1i* sin(pi*(x1)).*cos(pi*(x2))/( obj.kgrid.gridSize(n));
        end

        function BandLimGridPoint=BandLimGrid(obj,x1,x2,accuracy)
            BandLimGridPoint=1;
            for dim=1:obj.kgrid.dimensions
                if obj.kgrid.gridSize(dim)/2==ceil(obj.kgrid.gridSize(dim)/2)
                    BandLimGridPoint=BandLimGridPoint.*BandLimGridCoEven(obj,x1(:,dim),x2(:,dim),dim);
                else
                    BandLimGridPoint=BandLimGridPoint.*BandLimCoOdd(obj,x1(:,dim),x2(:,dim),dim);
                end
            end
            % BandLimGridPoint=ValidGridpointDistance(obj,x1,x2,accuracy).*BandLimGridPoint;
        end

        

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

        % Need to think about when a co-ordinate is shared, as may be the
        % case on a line as an example, limiting behaviour will be
        % difficult.

        function InvBandLimMatrix=InvBandLimMatrix(obj)
            BandLimMatrix= obj.BandLim(obj.gridLocations,obj.gridLocations);
            InvBandLimMatrix=inv(BandLimMatrix);
        end


    end

end
