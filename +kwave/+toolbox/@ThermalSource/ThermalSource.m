%% ThermalSource
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.GridInput
%
% Class used to define the source for a simulation.
%
%% Syntax
%   source = ThermalSource(kgrid);
%
%% Description
% This class is used to define the thermal source terms. The constructor
% takes an object of the |kwave.toolbox.Grid| class which defines the grid
% size. Source matrices must match the grid size defined by kgrid.
%
%% Examples
% Define the grid and source objects, and assign the initial temperature.
%
%    kgrid = kwave.toolbox.Grid([128, 128], 1e-3);
%    source = kwave.toolbox.ThermalSource(kgrid);
%    source.initialTemperature = rand(source.gridSize);
%
%% Properties
% * |initialTemperature| - (numeric) Initial temperature distribution [Pa].
%
%% See Also
% * |GridInput|

classdef ThermalSource < kwave.toolbox.GridInput

    properties(Constant, Hidden=true)
        requiredProperties = {};
        gridFields = kwave.toolbox.GridField.createGridFieldsMap([
            kwave.toolbox.GridField('initialTemperature', Attributes={'real', 'finite'})
        ]);
    end

end
