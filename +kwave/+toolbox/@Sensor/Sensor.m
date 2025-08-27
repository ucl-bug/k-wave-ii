%% Sensor
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.GridInput
%
% Class used to define the sensor locations and read the variables 
% to produce the sensor data.
%
%% Syntax
%   sensor = Sensor(kgrid);
%
%% Description
% This class is used to define the locations of sensors and to record
% the sensor data at time intervals. The sensor class must have a mask
% defined. and can be given an offFGrid object, using the BLI to constuct
% the sensor data.
%
%% Examples
% Define the grid and sensor objects, and assign the mask, both by defining
% a mask directly, and by using an offGrid object.
%
%    kgrid = kwave.toolbox.Grid([128, 128], 1e-3);
%    sensor = kwave.toolbox.Sensor(kgrid);
%    sensor.mask=zeros(128,128);
%    sensor.mask(12:254,12:24)=1;
%
%    sensor2=kwave.toolbox.Sensor(kgrid);
%    circ.radius=5e-2;
%    circ.centre=[0,0];
%    circ.points=315;
%    offGrid=OffGrid(kgrid,'circle',circ);
%    sensor2.setOffGrid(kgrid,offGrid,1e-4);
%    sensor2.mask=sensor2.maskBuilder;
%
%% Properties
% * |mask| - GridField type indicating grid locations that of 0,1's
% variable locations that contribute to the sensor data.
% * |maskbuilder| - For use with setOfFGrid to define the appropriate mask
% * |timeSteps| - (scalar positive integer), regularity of recorded sensor data
%   the number of time steps.
% * |sensorIndex| - Index numbers for sensor points
% * |totalSensorPoints| - The total number of sensor points
% * |BLIMat| - For use with the OffGrid methods, used to compute the sensor
% firled from the variables
% * |OffGridApplied| -  'on' 'off' witch that declares if offgrid methods
% are being used. automatically turned on when calling setOffGrid(OffGrid,accuracy)
% * |OffGrid| -  the Offgrid object used to call the oggrid methods.
%% See Also
% * |GridInput|
% * |AcousticSensor|
% * |OffGrid|
%

classdef Sensor < kwave.toolbox.GridInput

    properties(Constant, Hidden=true)
        requiredProperties = {'mask'};
        gridFields = kwave.toolbox.GridField.createGridFieldsMap([
            kwave.toolbox.GridField('mask', Attributes={'real', 'finite'})
            ]);
    end

    properties
        timeSteps(1,1) single {mustBeInteger, mustBeFinite, mustBePositive} = 1;
    end

    properties(Hidden)
        sensorIndex(1,1) single {mustBeInteger, mustBeFinite, mustBeNonnegative} = 0;
        totalSensorPoints =0;
        maskBuilder= 0;
        % Mask builder puts 1's in locations used for the computation of
        % the sensor data, used by sensor.mask=sensor.maskbuilder
        BLIMat =1;
        % Uses the Off-grid to compute the conversion matrix from the mask
        % to the off-grid points such that V(x)B(x,xi)=V(xi)
    end

    properties 
        OffGridApplied char {mustBeMember( OffGridApplied, {'off','on'})} = 'off'
        OffGrid kwave.toolbox.OffGrid
    end

    methods
        function obj=setOffGrid(obj,OffGrid,accuracy)
            obj.OffGrid=OffGrid;
            obj.OffGridApplied='on';
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

            % if min( obj.maskBuilder(1,:,:,:)==1,[],'all')==1 || min( obj.maskBuilder(end,:,:,:)==1,[],'all')==1 
            %     disp('Accuracy may be limited by proximity of off grid points to outer edge of the domain in x co-ordinate.')
            % end
            % if min( obj.maskBuilder(:,1,:,:)==1,[],'all')==1 || min( obj.maskBuilder(:,end,:,:)==1,[],'all')==1
            %     disp('Accuracy may be limited by proximity of off grid points to outer edge of the domain in y co-ordinate.')
            % end
            % if  min( obj.maskBuilder(:,:,1,:)==1,[],'all')==1 || min( obj.maskBuilder(:,:,end,:)==1,[],'all')==1
            %     disp('Accuracy may be limited by proximity of off grid points to outer edge of the domain in z co-ordinate.')
            % end
            
            obj.BLIMat = obj.OffGrid.BandLimGrid(gridLocations(Indexes==1,:),obj.OffGrid.gridLocations,accuracy);
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
        % function obj=multiDimMask(obj)
        %     obj.multiDimMask=zeros(obj.kgrid.gridSize,obj.kgrid.dimensions);
        %     for dim=1;obj.kgrid.dimensions
        %         obj.multiDimMask(:,:,:,dim)=obj.kgrid.returnWithoutGridPadding(obj.maskPadded);
        %     end
        % end
        function SensorOutput=ProcessSensorData(obj,Variable,dim,string)
            mask=obj.kgrid.returnWithoutGridPadding(obj.maskPadded);
            if ~strcmp(string,'sum')
                SensorOutput=zeros(obj.totalSensorPoints,dim);
                for dimension=1:dim
                    Var=Variable(:,:,:,dim);
                    SensorOutput(:,dim)=obj.BLIMat*Var(mask==1);
                end
            else
                SensorOutput=zeros(obj.totalSensorPoints,1);
                for dimension=1:dim
                    Var=Variable(:,:,:,dim);
                    SensorOutput=SensorOutput+obj.BLIMat*Var(mask==1);
                end
            end
        end
    end
end