%% ElasticSource
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.GridInput
%
% Class used to define the elastic sources for a simulation.
%
%% Syntax
%   source = ElasticSource(kgrid);
%
%% Description
% This class is used to define the elastic source terms. The constructor
% takes an object of the |kwave.toolbox.Grid| class which defines the grid
% size. Source matrices must match the grid size defined by kgrid.
%
%% Examples
% Define the grid and source objects, and assign the initial pressure.
%
%    kgrid = kwave.toolbox.Grid([128, 128], 1e-3);
%    source = kwave.toolbox.ElasticSource(kgrid);
%    source.initialPressure = rand(source.gridSize);
%
%% Properties
% * |initialPressure| - (numeric) Initial pressure distribution [Pa].
%% See Also
% * |GridInput|

classdef ElasticSource < kwave.toolbox.GridInput

    properties(Constant, Hidden=true)
        requiredProperties = {};
        gridFields = kwave.toolbox.GridField.createGridFieldsMap([
            kwave.toolbox.GridField('initialPressure', Attributes={'real', 'finite'})
        ]);
    end

end
