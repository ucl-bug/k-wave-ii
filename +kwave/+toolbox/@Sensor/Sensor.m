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
    end
end
