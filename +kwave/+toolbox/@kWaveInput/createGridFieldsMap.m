%% createGridFieldsMap
% *Class:* kwave.toolbox.kWaveInput
% *Package:* kwave.toolbox
%
% Constructs and returns a map of grid field properties based on provided
% definitions.
%
%% Syntax
%   fieldsMap = createGridFieldsMap(fieldDefinitions);
%
%% Description
% The |createGridFieldsMap| method is designed to create a |containers.Map|
% that provides dynamic handling and validation details for grid field
% properties. Each key of the map corresponds to a grid field property's
% name, and the associated value is a structure detailing the acceptable
% data classes and attributes for that property.
%
% This utility is crucial for the |kWaveInput| class to dynamically manage
% the addition and interaction of its grid-based properties.
%
%% Input Arguments
% * |fieldDefinitions| - (struct array) An array of structures where each
%   structure has three fields: 'name', which specifies the property
%   name, and 'classes' and 'attributes', which detail the acceptable data
%   types and characteristics for that property, respectively.
%
%% Output Arguments
% * |fieldsMap| - (containers.Map) A map where the keys are the property
%   names and the values are structures containing 'classes' and
%   'attributes' fields that detail the expected data type and attributes
%   for each respective property.

function fieldsMap = createGridFieldsMap(fieldDefinitions)

fieldsMap = containers.Map;
for i = 1:numel(fieldDefinitions)
    fieldsMap(fieldDefinitions(i).name) = ...
        struct('classes', {fieldDefinitions(i).classes}, ...
               'attributes', {fieldDefinitions(i).attributes});
end
