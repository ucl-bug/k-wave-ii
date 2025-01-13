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
        kGrid kwave.toolbox.Grid

        % Grid size [grid points].
        gridSize(1,1) double {mustBeInteger, mustBePositive, mustBeFinite} = [1];

        % Locations of the Points
        kGridLocations = [];

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
        function obj = OffGrid(kGrid, gridSize, kGridLocations,options)

            obj.kGrid = kGrid;
            obj.gridSize=prod(gridSize);

            if isnumeric(kGridLocations)
                %           assert(size(kGridLocations)==[obj.gridSize,obj.kGrid.dimensions] || size(kGridLocations)==[prod(obj.gridSize),obj.kGrid.dimensions])
                obj.kGridLocations = reshape(kGridLocations,[prod(obj.gridSize),obj.kGrid.dimensions]);

                assert(max(abs(obj.xLoc))<obj.kGrid.xSize/2)
                assert(max(abs(obj.yLoc))<obj.kGrid.ySize/2)
                assert(max(abs(obj.zLoc))<obj.kGrid.zSize/2)

            elseif ischar(kGridLocations)

                if strcmp(kGridLocations,'ball')
                    assert( ~isempty(options.radius), ~isempty(options.centre))
                    assert( obj.kGrid.dimensions==3)
                    assert( min(size(gridSize)==[1,2]) )

                    Nxi=gridSize(1);
                    Nyi=gridSize(2);
                    kGridLocations=zeros(Nxi,Nyi,3);

                    kGridLocations(:,:,1)=options.centre(1)+cos(0:2*pi/(Nxi-1):2*pi).'.*(cos(-pi/2:pi/(Nyi-1):pi/2));
                    kGridLocations(:,:,2)=options.centre(2)+sin(0:2*pi/(Nxi-1):2*pi).'.*(cos(-pi/2:pi/(Nyi-1):pi/2));
                    kGridLocations(:,:,3)=options.centre(3)+kGridLocations(:,:,3)+(sin(-pi/2:pi/(Nyi-1):pi/2));

                    kGridLocations=kGridLocations.*options.radius;
                    obj.kGridLocations = reshape(kGridLocations,[prod(obj.gridSize),obj.kGrid.dimensions]);

                    assert(max(abs(obj.xLoc))<obj.kGrid.xSize/2)
                    assert(max(abs(obj.yLoc))<obj.kGrid.ySize/2)
                    assert(max(abs(obj.zLoc))<obj.kGrid.zSize/2)

                elseif strcmp(kGridLocations,'circle')
                    assert( ~isempty(options.radius), ~isempty(options.centre))
                    assert( obj.kGrid.dimensions==2)
                    assert( min(size(gridSize)==[1,1]) )

                    Nxi=gridSize;
                    kGridLocations=zeros(Nxi,2);

                    kGridLocations(:,1)=options.centre(1)+options.radius.*cos(0:2*pi/(Nxi-1):2*pi);
                    kGridLocations(:,2)=options.centre(2)+options.radius.*sin(0:2*pi/(Nxi-1):2*pi);

                    obj.kGridLocations=kGridLocations;
                    assert(max(abs(obj.xLoc))<obj.kGrid.xSize/2)
                    assert(max(abs(obj.yLoc))<obj.kGrid.ySize/2)

                elseif strcmp(kGridLocations,'line')
                    assert( ~isempty(options.startpoint), ~isempty(options.endpoint))
                    assert(min(size(options.startpoint)==[1,2]));
                    assert(min(size(options.endpoint)==[1,2]));
                    assert( obj.kGrid.dimensions==2)
                    assert( min(size(gridSize)==[1,1]) )

                    Nxi=gridSize;
                    kGridLocations=zeros(Nxi,2);

                    kGridLocations(:,1)=((0.5:1:Nxi-0.5))*options.startpoint(1)/Nxi + ( 1- ((0.5:1:Nxi-0.5)/Nxi))*options.endpoint(1);
                    kGridLocations(:,2)=((0.5:1:Nxi-0.5))*options.startpoint(2)/Nxi + ( 1- ((0.5:1:Nxi-0.5)/Nxi))*options.endpoint(2);

                    obj.kGridLocations=kGridLocations;
                    assert(max(abs(obj.xLoc))<obj.kGrid.xSize/2)
                    assert(max(abs(obj.yLoc))<obj.kGrid.ySize/2)

                end


            end

        end
    end

    % Get methods for dependent properties.
    methods

        function xLoc = get.xLoc(obj)
            xLoc = obj.kGridLocations(:,1);
        end

        function yLoc = get.yLoc(obj)
            yLoc = obj.kGridLocations(:,2);
        end

        function zLoc = get.zLoc(obj)
            zLoc = obj.kGridLocations(:,3);
        end

    end

    methods

        function Val=ValidGridpointDistance(obj,x1,x2)
            accuracy=0.01;
            m=ceil(1/pi*accuracy);
            dist=0;
            Val=1;
            for dim=1:obj.kGrid.dimensions
                dist=dist+floor(abs(x1(dim)-x2(dim))/obj.kGrid.gridSpacing(dim));
                if dist>m
                    Val=0;
                    break
                end
            end
        end

        function BandLimPointCoOdd=BandLimPointCoOdd(obj,x1,x2,n)
            BandLimPointCoOdd = sin(pi*(x1-x2)/obj.kGrid.gridSpacing(n)) / ( obj.kGrid.gridSize(n) * sin (pi*(x1-x2)/( obj.kGrid.gridSize(n)*obj.kGrid.gridSpacing(n))) );
        end

        function BandLimGridPointCoEven=BandLimGridPointCoEven(obj,x1,x2,n)
            BandLimGridPointCoEven = sin(pi*(x1-x2)/obj.kGrid.gridSpacing(n)) / ( obj.kGrid.gridSize(n) * tan (pi*(x1-x2)/( obj.kGrid.gridSize(n)*obj.kGrid.gridSpacing(n))) );
        end

        function BandLimGridPoint=BandLimGridPoint(obj,x1,x2)
            if ValidGridpointDistance(obj,x1,x2)==0
                BandLimGridPoint=0;
            else
                BandLimGridPoint=1;
                for dim=1:obj.kgrid.dimensions
                    if obj.kgrid.GridSize(dim)/2==ceil(obj.kgrid.GridSize(dim)/2)
                        BandLimGridPoint=BandLimGridPoint*BandLimGridPointCoEven(obj,x1,x2,dim);
                    else
                        BandLimGridPoint=BandLimGridPoint*BandLimPointCoOdd(obj,x1,x2,dim);
                    end
                end
            end
        end

        function BandLimPointCoEven=BandLimPointCoEven(obj,x1,x2,n)
            BandLimPointCoEven = sin(pi*(x1-x2)/obj.kGrid.gridSpacing(n)) / ( obj.kGrid.gridSize(n) * tan (pi*(x1-x2)/( obj.kGrid.gridSize(n)*obj.kGrid.gridSpacing(n))) );
            BandLimPointCoEven(isnan(BandLimPointCoEven ))=1;
            BandLimPointCoEven = BandLimPointCoEven - sin(pi*(x1)/obj.kGrid.gridSpacing(n))*sin(pi*(x2)/obj.kGrid.gridSpacing(n))/( obj.kGrid.gridSize(n))  ...
                + 1i* sin(pi*(x1)/obj.kGrid.gridSpacing(n))*cos(pi*(x2)/obj.kGrid.gridSpacing(n))/( obj.kGrid.gridSize(n));
        end

        function BandLimPoint=BandLimPoint(obj,x1,x2)
            BandLimPoint=1;
            for dim=1:obj.kGrid.dimensions
                if obj.kGrid.gridSize(dim)/2==ceil(obj.kGrid.gridSize(dim)/2)
                    BandLimPoint=BandLimPoint*BandLimPointCoEven(obj,x1(dim),x2(dim),dim);
                else
                    BandLimPoint=BandLimPoint*BandLimPointCoOdd(obj,x1(dim),x2(dim),dim);
                end
            end
        end

        % Need to think about when a co-ordinate is shared, as may be the
        % case on a line as an example, limiting behaviour will be
        % difficult.

        function [BandLimMatrix,InvBandLimMatrix]=InvBandLimMatrix(obj)
            BandLimMatrix=zeros(obj.gridSize,obj.gridSize);
            for iInd=1:obj.gridSize
                for jInd=iInd:obj.gridSize
                    % if obj.ValidGridpointDistance(obj.kGridLocations(iInd,:),obj.kGridLocations(jInd,:))==1
                        BandLimMatrix(iInd,jInd)= obj.BandLimPoint(obj.kGridLocations(iInd,:),obj.kGridLocations(jInd,:));
                        if iInd~=jInd
                            BandLimMatrix(jInd,iInd)= obj.BandLimPoint(obj.kGridLocations(jInd,:),obj.kGridLocations(iInd,:));
                        end
                    % end
                end
            end
            InvBandLimMatrix=inv(BandLimMatrix);
        end


    end

end
