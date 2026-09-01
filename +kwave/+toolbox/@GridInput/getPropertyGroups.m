%% getPropertyGroups
% *Class:* kwave.toolbox.GridInput
% *Package:* kwave.toolbox
%
% Overloads the |matlab.mixin.CustomDisplay| method to return a property
% group for enhanced display in the MATLAB command window.
%
%% Syntax
%   propgrp = getPropertyGroups(obj);
%
%% Description
% The |getPropertyGroups| method, an overload of
% |matlab.mixin.CustomDisplay|, is designed to enhance the display of the
% |GridInput| class object when viewed in the MATLAB command window. By
% grouping properties and using the overridden |subsref| method, this
% function ensures that both static and virtual properties of the object
% are presented in a structured manner.
%
% The intention behind this method is to provide clarity to users when they
% inspect the object, making it easier to understand the object's current
% state, especially in the context of its virtual properties.
%
%% Input Arguments
% * |obj| - (kwave.toolbox.GridInput) An instance of the
%   |kwave.toolbox.GridInput| class.
%
%% Output Arguments
% * |propgrp| - (matlab.mixin.util.PropertyGroup) A property group object
%   that represents the structured view of the object's properties,
%   suitable for display in the MATLAB command window.

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

function propgrp = getPropertyGroups(obj)

propertyStruct = struct();
for ind = 1:numel(obj.properties)
    propertyStruct.(obj.properties{ind}) = obj.subsref(struct('type', '.', 'subs', obj.properties{ind}));
end
propgrp = matlab.mixin.util.PropertyGroup(propertyStruct);
