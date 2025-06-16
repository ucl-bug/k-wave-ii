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
    end

%% Add method to initialise sensor reading

%% Add method to record sensor reading, this way when off-grid overwrites it can use the offgrid methods in recording

%% Acoustic sensor then needs to be able to set up and use multiple sensors as required

end
