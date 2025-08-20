% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.GridInput
%
% The Boundary Condition class is a set of methods that can be applied to a
% general variable to alter it's value at a set of given points, 'the
% boundary.' This can be done by setting a mask with the grid, or by
% assigning an OffGrid. Subclasses contain methods for the passing of the
% correct variables and calling the methods.
%
%% Syntax
%   BoundaryCondition = BoundaryCondition(kgrid);
%
%% Description
%  The Boundary Condition class acts similarly to the sensor class. When
%  constucted a mask must be generated. This can be either by writing the
%  mask manually for a on-grid boundary. Or by assigning an off-grid object
%  and using the mask builder.  The methods contained adapt based on the
%  presence of the BLI terms when an offgrid is applied, with these set to
%  1's when on grid methods are used.
%% Examples
%    kgrid = kwave.toolbox.Grid([128, 128], 1e-3);
%    BoundaryCondition = kwave.toolbox.BoundaryCondition(kgrid);
%    BoundaryCondition.mask=zeros(128,128);
%    BoundaryCondition.mask(12,:)=1;
%    BoundaryCondition.bndryVal=0;
%
%    BoundaryCondition2=kwave.toolbox.BoundaryCondition(kgrid);
%    circ.radius=5e-2;
%    circ.centre=[0,0];
%    circ.points=315;
%    offGrid=OffGrid(kgrid,'circle',circ);
%    BoundaryCondition2.setOffGrid(kgrid,offGrid,1e-4);
%    BoundaryCondition2.mask=BoundaryCondition2.maskBuilder;
%    BoundaryCondition2.bndryVal=0;
%
%% Properties
% * |mask|
% * |OffGridApplied| -  'on' 'off' witch that declares if offgrid methods
% are being used. automatically turned on when calling setOffGrid(OffGrid,accuracy)
% * |OffGrid| -  the Offgrid object used to call the oggrid methods.
% * |normal| - the outward unit normal to the boundary for use in the
% neumann boundary condition, NOT YET IMPLEMENTED
% * |bndryVal| - scalar or vecot of values of the time invariant value at
% the boundary of the domain. Defaults to 0.
%% See Also
% * |GridInput|
% * |OffGrid|
%

classdef BoundaryCondition < kwave.toolbox.GridInput

    properties(Constant, Hidden=true)
        requiredProperties = {'mask'};
        gridFields = kwave.toolbox.GridField.createGridFieldsMap([
            kwave.toolbox.GridField('mask', Attributes={'real', 'finite'})
            ]);
    end

    properties(Hidden)
        sensorIndex(1,1) single {mustBeInteger, mustBeFinite, mustBeNonnegative} = 0;
        totalSensorPoints =0;
        maskBuilder= 0;
        BLIMat =1;
        BoundaryScaleMatrix=1;
    end

    properties 
        OffGridApplied char {mustBeMember( OffGridApplied, {'off','on'})} = 'off'
        OffGrid kwave.toolbox.OffGrid
        normal 
        bndryVal = 0;
    end

    methods
        function obj=setOffGrid(obj,OffGrid,accuracy)
            obj.OffGrid=OffGrid;
            obj.OffGridApplied='on';
            if nargin<2
                accuracy=0.05;
            end
            obj.maskBuilder= zeros(obj.kgrid.gridSize);
            gridLocations=zeros(obj.kgrid.totalGridPoints,obj.kgrid.dimensions);

            for j1=1:obj.kgrid.totalGridPoints
                switch obj.kgrid.dimensions
                    case 1
                        gridPoint=obj.kgrid.x(j1)/obj.kgrid.gridSpacing(1);
                    case 2
                        gridPoint=[obj.kgrid.x(j1)/obj.kgrid.gridSpacing(1),obj.kgrid.y(j1)/obj.kgrid.gridSpacing(2)];
                    case 3
                        gridPoint=[obj.kgrid.x(j1)/obj.kgrid.gridSpacing(1),obj.kgrid.y(j1)/obj.kgrid.gridSpacing(2),obj.kgrid.z(j1)/obj.kgrid.gridSpacing(3)];
                end
                gridLocations(j1,:)=gridPoint;
            end
            Indexes=obj.OffGrid.ValidGridpointDistance(gridLocations,obj.OffGrid.gridLocations,accuracy);
            Indexes=max(Indexes,[],1);
            obj.maskBuilder(Indexes==1)=1;
            
            obj.BLIMat = obj.OffGrid.BandLimGrid(gridLocations(Indexes==1,:),obj.OffGrid.gridLocations,accuracy);
            obj.BoundaryScaleMatrix=obj.OffGrid.InvBandLimMatrix;
            obj.normal=OffGrid.normal;
        end
    end

    methods
        function totalSensorPoints=get.totalSensorPoints(obj)
            if strcmp(obj.OffGridApplied,'off')
                obj.totalSensorPoints= sum(obj.kgrid.returnWithoutGridPadding(obj.maskPadded),'all');
            else
                obj.totalSensorPoints= obj.OffGrid.gridSize;
            end
            totalSensorPoints=obj.totalSensorPoints;
        end

        function SensorOutput=ProcessSensorData(obj,Variable,dim,string)
            mask=obj.kgrid.returnWithoutGridPadding(obj.maskPadded);
            if ~strcmp(string,'sum')
                SensorOutput=zeros(obj.totalSensorPoints,dim);
                for dimension=1:dim
                    Var=Variable(:,:,:,dimension);
                    SensorOutput(:,dimension)=obj.BLIMat*Var(mask==1);
                end
            else
                SensorOutput=zeros(obj.totalSensorPoints,1);
                for dimension=1:dim
                    Var=VariablePadded(:,:,:,dim);
                    SensorOutput=SensorOutput+obj.BLIMat*Var(mask==1);
                end
            end
        end

        function Mat=ExpansionFunction(obj,Matrix) 
            switch obj.kgrid.dimensions
                case 1
                     Mat=kwave.toolbox.expandMatrix(   Matrix, obj.kgrid.gridPadding(1),0);
                case 2
                    Mat=kwave.toolbox.expandMatrix(   Matrix, [obj.kgrid.gridPadding(1),obj.kgrid.gridPadding(1),obj.kgrid.gridPadding(2),obj.kgrid.gridPadding(2)],0);
                case 3
                    Mat=kwave.toolbox.expandMatrix(   Matrix, [obj.kgrid.gridPadding(1),obj.kgrid.gridPadding(1),obj.kgrid.gridPadding(2),obj.kgrid.gridPadding(2),obj.kgrid.gridPadding(3),obj.kgrid.gridPadding(3)],0);
            end
        end

        function VariablePadded = ApplyBoundaryCondition(obj,VariablePadded,bndrytype,dim,string)
            Variable=obj.kgrid.returnWithoutGridPadding(VariablePadded);
            BoundaryValue =obj.ProcessSensorData(Variable,dim,string);
            mask=obj.kgrid.returnWithoutGridPadding(obj.maskPadded);
            
            if strcmp(bndrytype,'dirichlet')
                Change=obj.BoundaryScaleMatrix*(obj.bndryVal - BoundaryValue);
                
                for dimension=1:length(Change(1,1,1,:))
                    Var=zeros(size(Variable(:,:,:,dimension)));
                    Var(mask==1) = + real((obj.BLIMat.' * Change(:,:,:,dimension))); %Check, what does change look like? dim 2 in 2D?
                        VariablePadded(:,:,:,dimension)=VariablePadded(:,:,:,dimension) + obj.ExpansionFunction(Var);
                end
            elseif strcmp(bndrytype,'neumann')
                Change=obj.BoundaryScaleMatrix*(obj.bndryVal - sum(BoundaryValue.*obj.normal,2));
                for dimension=1:dim
                    Var=VariablePadded(:,:,:,dimension);
                    Var(obj.maskPadded==1)=Var(obj.maskPadded==1) + Change(:,dimension).*obj.normal(:,dimension);
                    VariablePadded(:,:,:,dimension)=Var;
                end
            end
        end
    end
end