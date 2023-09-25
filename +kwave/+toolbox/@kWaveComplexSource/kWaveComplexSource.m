%% kWaveComplexSource
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.kWaveInput
%
% Class used to define complex sources for a simulation.
%
%% Syntax
%   source = kWaveComplexSource(kgrid);
%
%% Description
% This class is used to define complex valued source terms. The constructor
% takes an object of the |kWaveGrid| class which defines the grid size.
% Source matrices must match the grid size defined by |kgrid|. 
%
%% Examples
% Define the grid and source objects, and assign the source field.
%
%    kgrid = kwave.toolbox.kWaveGrid([128, 128], 1e-3);
%    source = kwave.toolbox.kWaveComplexSource(kgrid);
%    source.sourceField = rand(source.gridSize) + 1i * rand(source.gridSize);
%
%% Properties
% * |sourceField| - (complex) Complex source field distribution [Pa + i*rad].
% * |sourceFieldMagnitude| - (single) Magnitude of the complex source field [Pa].
% * |sourceFieldPhase| - (single) Phase of the complex source field [radians]. 
%
%% See Also
% * |kwave.toolbox.kWaveInput|

classdef kWaveComplexSource < kwave.toolbox.kWaveInput
  
    properties(Dependent=true)
        sourceField {kwave.utilities.mustBeEmptyOrComplex(sourceField)}
        sourceFieldMagnitude single
        sourceFieldPhase single
    end

    properties(Hidden=true)
        sourceFieldPadded {kwave.utilities.mustBeEmptyOrComplex(sourceFieldPadded)}
    end

    properties(Constant, Hidden=true)
        requiredProperties = {};
    end

    % Set and Get methods
    methods

        function set.sourceFieldPadded(obj, value)
            obj.kgrid.validateSize(value, variableName='sourceFieldPadded', IncludePadding=true)
            obj.sourceFieldPadded = value;
        end
        
        function set.sourceField(obj, value)
            obj.kgrid.validateSize(value, variableName='sourceField')
            obj.sourceFieldPadded = obj.kgrid.assignWithGridPadding(value);
        end

        function sourceField = get.sourceField(obj)
            sourceField = obj.kgrid.returnWithoutGridPadding(obj.sourceFieldPadded);
        end
    
    end

    % Properties
    methods

        % Returns the magnitude of the source field
        function sourceFieldMagnitude = get.sourceFieldMagnitude(obj)
            sourceFieldMagnitude = abs(obj.sourceField);
        end

        % Returns the phase of the source field
        function sourceFieldPhase = get.sourceFieldPhase(obj)
            sourceFieldPhase = angle(obj.sourceField);
        end
    
    end

end

