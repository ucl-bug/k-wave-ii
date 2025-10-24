%% Create Grid Fields Map
% *Class:* kwave.toolbox.GridField
% *Package:* kwave.toolbox
%
% Constructs and returns a map of grid field properties based on provided
% definitions.
%
%% Syntax
%   fieldsMap = createGridFieldsMap(fieldDefinitions);
%
%% Description
% The |createGridFieldsMap| method is designed to create a
% |<https://uk.mathworks.com/help/matlab/ref/containers.map.html containers.Map>| that provides handling
% and validation details for grid field properties. Each key of the map
% corresponds to a grid field property's name, and the associated value is
% a |kwave.toolbox.GridField| object. This utility is used to generate the
% |gridFields| property for classes derived from
% |kwave.toolbox.GridInput|.
%
%% Input Arguments
% * |fieldDefinitions| - (|kwave.toolbox.GridField| array) An array of
%   |kwave.toolbox.GridField| objects.
%
%% Output Arguments
% * |fieldsMap| - (|containers.Map|) A map where the keys are the property
%   names and the values are |kwave.toolbox.GridField|

function fieldsMap = createGridFieldsMap(fieldDefinitions)

fieldsMap = containers.Map;
for i = 1:numel(fieldDefinitions)
    fieldsMap(fieldDefinitions(i).name) = fieldDefinitions(i);
end
