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

% Copyright (C) 2024- The k-Wave Authors.
%
% This file is part of k-Wave-II (http://www.k-wave.org). k-Wave-II is free
% software: you can redistribute it and/or modify it under the terms of the
% GNU Lesser General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any
% later version.
%
% k-Wave-II is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
% License for more details.
%
% You should have received a copy of the GNU Lesser General Public License
% along with k-Wave-II. If not, see <http://www.gnu.org/licenses/>.

function fieldsMap = createGridFieldsMap(fieldDefinitions)

fieldsMap = containers.Map;
for i = 1:numel(fieldDefinitions)
    fieldsMap(fieldDefinitions(i).name) = fieldDefinitions(i);
end
