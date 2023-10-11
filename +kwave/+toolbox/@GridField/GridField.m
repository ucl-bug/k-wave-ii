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
%   <matlab:doc('validateattributes') validateattributes>.
% * |Attributes| - (cell array) Valid attributes passed to
%   <matlab:doc('validateattributes') validateattributes>.
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
%
%% Methods
% * |createGridFieldsMap| - Static utility method to define a map for grid
%   field properties.

classdef GridField < handle

    properties
        name char
        classes cell
        attributes cell
        expansionValue {mustBeScalarOrEmpty}
    end

    methods

        % Constructor
        function obj = GridField(name, options)
            arguments
                name
                options.Classes = {'numeric'}
                options.Attributes = {'real', 'positive', 'finite'}
                options.ExpansionValue = []
            end

            obj.name = name;
            obj.classes = options.Classes;
            obj.attributes = options.Attributes;
            obj.expansionValue = options.ExpansionValue;
        end

    end

    methods(Static)
        fieldsMap = createGridFieldsMap(fieldDefinitions);
    end

end
