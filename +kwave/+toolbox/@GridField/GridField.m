%% GridField
% *Package:* kwave.toolbox
%
% Container class for grid field inputs.
%
%% Description
% Simple container class used to specify virtual properties for classes
% deriving from |kwave.toolbox.GridInput|.
%
%% Input Arguments
% * |name| - (char) Name of the virtual property.
%
%% Name-Value Arguments
% Specify optional pairs of arguments as |Name1=Value1,...,NameN=ValueN|,
% where |Name| is the argument name and |Value| is the corresponding value.
% Name-value arguments must appear after other arguments, but the order of
% the pairs does not matter.
%
% * |Classes| - (cell array) Valid data types passed to
%   <https://uk.mathworks.com/help/matlab/ref/validateattributes.html validateattributes>.
% * |Attributes| - (cell array) Valid attributes passed to
%   <https://uk.mathworks.com/help/matlab/ref/validateattributes.html validateattributes>.
% * |ExpansionValue| - (cell array) Scalar value to use in the matrix
%   expansion passed to |kwave.toolbox.expandMatrix|.
%
%% Properties
% * |name| - (char) Name of the grid property.
% * |classes| - (cell array) Valid data types. Default = {'numeric'}.
% * |attributes| - (cell array) Valid attributes. Default = {'real',
%   'positive', 'finite'}.
% * |expansionValue| - (numeric) Value used in matrix expansion. Default =
%   [].
% * |type| = (kwave.toolbox.GridFieldsType) Field type used for size
%   validation. Default = kwave.toolbox.GridFieldTypes.ScalarField.
%
%% Methods
% * |createGridFieldsMap| - Static utility method to define a map for grid
%   field properties.

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

classdef GridField < handle

    properties
        name char
        classes cell
        attributes cell
        expansionValue {mustBeScalarOrEmpty}
        type kwave.toolbox.GridFieldType
    end

    methods

        % Constructor
        function obj = GridField(name, options)
            arguments
                name
                options.Classes = {'numeric'}
                options.Attributes = {'real', 'positive', 'finite'}
                options.ExpansionValue = []
                options.Type = kwave.toolbox.GridFieldType.ScalarField
            end

            obj.name = name;
            obj.classes = options.Classes;
            obj.attributes = options.Attributes;
            obj.expansionValue = options.ExpansionValue;
            obj.type = options.Type;
        end

    end

    methods(Static)
        fieldsMap = createGridFieldsMap(fieldDefinitions);
    end

end
