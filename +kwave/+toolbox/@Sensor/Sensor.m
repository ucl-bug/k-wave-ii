%% Sensor
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.GridInput
%
%% Syntax
%
%% Description
%
%% Examples
%
%% Properties
%
%% See Also
%
%% Writing Notes
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
    end

    methods
        function totalSensorPoints=get.totalSensorPoints(obj)
            obj.totalSensorPoints= sum(obj.kgrid.returnWithoutGridPadding(obj.maskPadded),'all');
            totalSensorPoints=obj.totalSensorPoints;
        end
        function obj=multiDimMask(obj)
            obj.multiDimMask=zeros(obj.kgrid.gridSize,obj.kgrid.dimensions);
            for dim=1;obj.kgrid.dimensions
                obj.multiDimMask(:,:,:,dim)=obj.kgrid.returnWithoutGridPadding(obj.maskPadded);
            end
        end
        function SensorOutput=ProcessSensorData(obj,Variable,dim,string)
            mask=obj.kgrid.returnWithoutGridPadding(obj.maskPadded);
            if ~strcmp(string,'sum')
                SensorOutput=zeros(obj.totalSensorPoints,dim);
                for dimension=1:dim
                    Var=Variable(:,:,:,dim);
                    SensorOutput(:,dim)=Var(mask==1);
                end
            else
                SensorOutput=zeros(obj.totalSensorPoints,1);
                for dimension=1:dim
                    Var=Variable(:,:,:,dim);
                    SensorOutput=SensorOutput+Var(mask==1);
                end
            end
        end
    end
end