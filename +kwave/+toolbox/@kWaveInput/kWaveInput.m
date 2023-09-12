%% kWaveInput
% *Package:* kwave.toolbox
%
% Superclass of all kwave.toolbox input classes.
%
%% Description
% Abstract class used as a container to define grid-based inputs for k-Wave
% simulation functions. Input classes used for the k-Wave simulation
% functions should be derived from this class.
%
% Simulations in k-Wave are often performed on a padded grid, for example,
% to incorporate a perfectly matched layer. The expansion of the grid-based
% medium, source, and sensor inputs is devolved to these classes. Any
% grid-based inputs should thus be expanded from |kgrid.gridSize| to
% |kgrid.gridSize + 2*kgrid.gridPadding| before storing. This should be
% performed within the corresponding set method. Similarly, the padding
% should be removed from the stored variable before returning to the user
% within the corresponding get method. This approach allows the user to
% continue to use and modify the grid-based properties ignoring the grid
% padding.
%
% Within the derived classes, the padded versions should be assigned as
% hidden properties, which can then be used directly inside the solver
% classes. The non-padded properties should be assigned as dependent
% properties with set and get methods as described above. |kWaveGrid|
% provides the |assignWithGridPadding| method for automatically padding an
% input, and |returnWithoutGridPadding| for automatically contracting it.
%
% Inputs should list required attributes as part of their declaration. For
% example, if a property must be real and finite, this should be declared.
% In general, properties should also be defined in single precision, unless
% there is a specific precision requirement.
%
% Derived classes must also define a cell array of |requiredProperties| as
% a |Constant| property. A check that these properties are not empty is
% done within the |kWaveSolver| constructor using the
% |checkRequiredProperties| method. If there are no required properties,
% |requiredProperties| should be defined as |{}|.
%
%% Examples
% A simple example of a derived class with a single grid-based property
% (|myProperty|) is shown below. Note how the get/set methods for the
% dependent property automatically perform the grid expansion and
% contraction. Input size validation is performed using the |validateSize|
% method of the |kWaveGrid| class.
%
%   classdef MyMedium < kwave.toolbox.kWaveInput  
%       properties(Hidden=true)
%           myPropertyPadded single {mustBeReal, mustBeFinite}
%       end
%       properties(Dependent=true)
%           myProperty single {mustBeReal, mustBeFinite}
%       end
%       properties(Constant, Hidden=true)
%           requiredProperties = {'myProperty'};
%       end
%       methods
%           function set.myProperty(obj, val)
%               obj.kgrid.validateSize(val, VariableName='myProperty');
%               obj.myPropertyPadded = obj.kgrid.assignWithGridPadding(val);
%           end
%           function set.myPropertyPadded(obj, val)
%               obj.kgrid.validateSize(val, VariableName='myProperyPadded', IncludePadding=true);
%               obj.myPropertyPadded = val;
%           end
%           function myProperty = get.myProperty(obj)
%               myProperty = obj.kgrid.returnWithoutGridPadding(obj.myPropertyPadded);
%           end
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
%
%% Methods
% * |checkRequiredProperties|

classdef(Abstract) kWaveInput < handle

    % Properties set by constructor.
    properties(SetAccess=immutable)
        kgrid kwave.toolbox.kWaveGrid
    end

    % Dependent properties without set methods. These parameters are not
    % stored but re-computed each time they are needed.
    properties(Dependent=true, GetAccess=public, SetAccess=private)
        gridSize;
    end

    % Cell array of required properties. This should be redefined in
    % derived classes.
    properties(Abstract, Constant, Hidden=true)
        requiredProperties;
    end

    % Constructor.
    methods
        function obj = kWaveInput(kgrid)
            arguments
                kgrid(1,1) kwave.toolbox.kWaveGrid
            end
            obj.kgrid = kgrid;
        end
    end

    % Get methods for dependent properties.
    methods

        % Convenience function to get the grid size from the stored
        % kWaveGrid.
        function sz = get.gridSize(obj)
            sz = obj.kgrid.gridSize;
        end

    end

    % General class methods with a concrete implementation.
    methods
        checkRequiredProperties(obj);
    end

end
