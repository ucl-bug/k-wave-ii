%% kWaveInput
% *Package:* kwave.toolbox
% *Superclasses:* dynamicprops, matlab.mixin.CustomDisplay
%
% Abstract superclass defining the structure and behavior of all k-Wave
% grid-based input classes.
%
%% Description
% This abstract class provides a unified structure for managing grid-based
% inputs for k-Wave simulations. It encapsulates the logic for managing
% grid padding, which is often essential for simulations, especially when
% incorporating a perfectly matched layer. This design ensures that user
% interactions with properties are abstracted away from the internal grid
% padding mechanism.
%
% One of the key features of this class is the concept of "virtual
% properties". Instead of directly interacting with the actual stored
% properties that include the padded grid, users interact with a set of
% virtual properties that reflect the non-padded grid. Behind the scenes,
% whenever a user accesses or modifies one of these virtual properties, the
% class internally maps this interaction to the padded variant, ensuring
% that the simulation uses the correctly padded values while presenting a
% simpler and more intuitive interface to the user.
%
% Features of the class include:
% * Dynamic property management: This class uses dynamic properties
%   to efficiently handle grid field properties, automatically taking care
%   of grid padding.
% * Grid-based input validation: The class integrates with the kWaveGrid
%   object to ensure that the grid-based inputs align with the defined grid
%   size.
% * Required property checks: The class ensures that all required
%   properties for a given simulation are set before execution.
%
%% Note on Property Access
% Due to the internal design of the class and the way properties are
% managed, it is recommended to access "virtual" properties (those
% without direct storage in the class but exist due to grid padding
% mechanisms) within class methods using:
%
%   obj.subsref(struct('type', '.', 'subs', propertyName))
%
% instead of the standard:
%
%   obj.(propertyName)
%
% where propertyName is a char holding the property name. This ensures
% consistent access to the properties, considering the custom behaviors
% introduced by the overloaded subsref method.
%
%% Examples
% A simple example of a derived class with a single grid-based property
% (|myProperty|) is shown below. The derived class must define
% |requiredProperties| and |gridFields|
%
%   classdef MyMedium < kwave.toolbox.kWaveInput  
%       properties(Constant, Hidden=true)
%           requiredProperties = {'myProperty'};
%           gridFields = kwave.toolbox.kWaveInput.createGridFieldsMap([
%               struct('name', 'myProperty', 'classes', {{'numeric'}}, 'attributes', {{'real', 'positive', 'finite'}})
%           ]);
%       end
%   end
%
% Save the example above into a file called |MyMedium.m|. Then, the class
% can be tested. First define the grid and medium objects.
%
%    kgrid = kwave.toolbox.kWaveGrid([128, 128], 1e-3, [10, 10]);
%    medium = MyMedium(kgrid);
%
% The default object has no assigned properties. We can verify that the
% required properties are not yet defined by calling
% |checkRequiredProperties|.
%
%    medium.checkRequiredProperties;
%    Error using kwave.toolbox.kWaveInput/checkRequiredProperties
%    The property myProperty must be defined.
%
% Finally, assign the required property and examine its size. |myProperty|
% has the same size as |kgrid.gridSize|, while the internal
% |myPropertyPadded| includes |kgrid.gridPadding|.
%
%    medium.myProperty = rand(medium.gridSize);
%    medium.checkRequiredProperties;
%    size(medium.myProperty)
%    
%    ans =
%    
%       128   128
%    
%    size(medium.myPropertyPadded)
%    
%    ans =
%    
%       148   148
%
%% Input Arguments
% * |kgrid| - (kWaveGrid) kWaveGrid object which defines the simulation
%   grid size.
%
%% Properties
% * |kgrid| - (kWaveGrid) Handle for kWaveGrid object.
% * |gridSize| - (double) Number of grid points in each Cartesian direction
%   [grid points]. Convenience property that returns kgrid.gridSize.
% * |requiredProperties| - (cell array) List of properties that must be 
%   set for the simulation. Defined in derived classes.
% * |gridFields| - (containers.Map) Map containing the attributes 
%   and validation criteria for each grid field. Defined in derived
%   classes.
%
%% Methods
% * |checkRequiredProperties| - Ensures all required properties for the
%   simulation are set.
% * |createGridFieldsMap| - Static utility method to define a map for grid
%   field properties.
% * |getPropertyGroups| - Overloaded method from the
%   matlab.mixin.CustomDisplay mixin to customize object display.
% * |properties| - Overloaded method that returns both normal and virtual
%   properties.
% * |subsasgn| - Overloaded method for setting properties. It ensures that
%   properties defined in |gridFields| are correctly padded.
% * |subsref| - Overloaded method for accessing properties. It returns the
%   properties defined in |gridFields| without padding.

classdef(Abstract) kWaveInput < dynamicprops & matlab.mixin.CustomDisplay

    % Properties set by constructor.
    properties(SetAccess=immutable)
        kgrid;
    end

    % Dependent properties without set methods.
    properties(Dependent=true, GetAccess=public, SetAccess=private)
        gridSize;
    end

    % Properties defined in derived classes.
    properties(Abstract, Constant, Hidden=true)
        requiredProperties;
        gridFields containers.Map;
    end

    % Constructor.
    methods
        function obj = kWaveInput(kgrid)

            arguments
                kgrid(1,1) kwave.toolbox.kWaveGrid
            end
            obj.kgrid = kgrid;

            % Dynamically add properties to the class based on the
            % gridFields map. The properties names are appended with
            % 'Padded'.
            propertyKeys = keys(obj.gridFields);
            for i = 1:length(propertyKeys)
                paddedName = strcat(propertyKeys{i}, 'Padded');
                prop = addprop(obj, paddedName);
                prop.Hidden = true;
            end

        end

        % Override the in-built properties method so that the virtual
        % properties are also visible to the user. (Note, this cannot be
        % moved to an external file and declared under methods like other
        % class methods due to the conflict between the MATLAB properties
        % declaration and the in-built properties function.)
        function propList = properties(obj)

            % Call the built-in properties method
            propList = builtin('properties', obj);

            % Add the virtual property names to the list
            virtualProperties = keys(obj.gridFields);
            propList = [propList; virtualProperties(:)];

        end

        % Convenience function to get the grid size from the stored
        % kWaveGrid.
        function sz = get.gridSize(obj)
            sz = obj.kgrid.gridSize;
        end

    end

    % General class methods with a concrete implementation.
    methods
        checkRequiredProperties(obj);
        obj = subsasgn(obj, S, value);
        value = subsref(obj, S);
    end

    methods (Access = protected)
        propgrp = getPropertyGroups(obj);
    end

    methods(Static)
        fieldsMap = createGridFieldsMap(fieldDefinitions);
    end

end
