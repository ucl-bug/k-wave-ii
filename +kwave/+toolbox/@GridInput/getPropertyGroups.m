%% getPropertyGroups
% *Class:* kwave.toolbox.kWaveInput
% *Package:* kwave.toolbox
%
% Overloads the matlab.mixin.CustomDisplay method to return a property
% group for enhanced display in the MATLAB command window.
%
%% Syntax
%   propgrp = getPropertyGroups(obj);
%
%% Description
% The |getPropertyGroups| method, an overload of
% |matlab.mixin.CustomDisplay|, is designed to enhance the display of the
% |kWaveInput| class object when viewed in the MATLAB command window. By
% grouping properties and using the overridden |subsref| method, this
% function ensures that both static and virtual properties of the object
% are presented in a structured manner.
%
% The intention behind this method is to provide clarity to users when they
% inspect the object, making it easier to understand the object's current
% state, especially in the context of its virtual properties.
%
%% Input Arguments
% * |obj| - (kwave.toolbox.kWaveInput) An instance of the
%   |kwave.toolbox.kWaveInput| class.
%
%% Output Arguments
% * |propgrp| - (matlab.mixin.util.PropertyGroup) A property group object
%   that represents the structured view of the object's properties,
%   suitable for display in the MATLAB command window.

function propgrp = getPropertyGroups(obj)

propertyStruct = struct();
for ind = 1:numel(obj.properties)
    propertyStruct.(obj.properties{ind}) = obj.subsref(struct('type', '.', 'subs', obj.properties{ind}));
end
propgrp = matlab.mixin.util.PropertyGroup(propertyStruct);
