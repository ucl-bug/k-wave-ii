%% kWaveThermalSource
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.kWaveInput
%
% Class used to define the source for a simulation.
%
%% Syntax
%   source = kWaveThermalSource(kgrid);
%
%% Description
% This class is used to define the thermal source terms. The constructor
% takes an object of the |kwave.toolbox.kWaveGrid| class which defines the
% grid size. Source matrices must match the grid size defined by kgrid.
%
%% Examples
% Define the grid and source objects, and assign the initial temperature.
%
%    kgrid = kwave.toolbox.kWaveGrid([128, 128], 1e-3);
%    source = kwave.toolbox.kWaveThermalSource(kgrid);
%    source.initialTemperature = rand(source.gridSize);
%
%% Properties
% * |initialTemperature| - (numeric) Initial temperature distribution [Pa].
%
%% See Also
% * |kWaveInput|

classdef kWaveThermalSource < kwave.toolbox.kWaveInput

    properties(Constant, Hidden=true)
        requiredProperties = {};
        gridFields = kwave.toolbox.kWaveInput.createGridFieldsMap([
            struct('name', 'initialTemperature', 'classes', {{'numeric'}}, 'attributes', {{'real', 'finite'}})
        ]);
    end

end
