%% ComplexSource
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.GridInput
%
% Class used to define complex sources for a simulation.
%
%% Syntax
%   source = ComplexSource(kgrid);
%
%% Description
% This class is used to define complex valued source terms. The constructor
% takes an object of the |kwave.toolbox.Grid| class which defines the grid
% size. Source matrices must match the grid size defined by |kgrid|.
%
%% Examples
% Define the grid and source objects, and assign the source field.
%
%    kgrid = kwave.toolbox.Grid([128, 128], 1e-3);
%    source = kwave.toolbox.ComplexSource(kgrid);
%    source.sourceField = rand(source.gridSize) + 1i * rand(source.gridSize);
%
%% Properties
% * |sourceField| - (numeric) Complex source field distribution [Pa +
%   i*rad].
% * |sourceFieldMagnitude| - (numeric) Magnitude of the complex source
%   field [Pa].
% * |sourceFieldPhase| - (numeric) Phase of the complex source field
%   [radians].
%
%% See Also
% * |kwave.toolbox.GridInput|

classdef ComplexSource < kwave.toolbox.GridInput
  
    properties(Dependent=true)
        sourceFieldMagnitude
        sourceFieldPhase
    end

    properties(Constant, Hidden=true)
        requiredProperties = {};
        gridFields = kwave.toolbox.GridField.createGridFieldsMap([
            kwave.toolbox.GridField('sourceField', Attributes={'finite'})
        ]);
    end

    % Properties
    methods

        % Returns the magnitude of the source field
        function sourceFieldMagnitude = get.sourceFieldMagnitude(obj)
            sourceFieldMagnitude = abs(obj.subsref(struct('type', '.', 'subs', 'sourceField')));
        end

        % Returns the phase of the source field
        function sourceFieldPhase = get.sourceFieldPhase(obj)
            sourceFieldPhase = angle(obj.subsref(struct('type', '.', 'subs', 'sourceField')));
        end
    
    end

end
