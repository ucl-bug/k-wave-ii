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
% takes an object of the kWaveGrid class which defines the grid size.
% Source matrices must match the grid size defined by kgrid. Inputs are
% cast to single precision.
%
%% Examples
% Define the grid and source objects, and assign the initial temperature.
%
%    kgrid = kwave.toolbox.kWaveGrid([128, 128], 1e-3);
%    source = kwave.toolbox.kWaveThermalSource(kgrid);
%    source.initialTemperature = rand(source.gridSize);
%
%% Properties
% * |initialTemperature| - (single) Initial temperature distribution [Pa].
%
%% See Also
% * |kWaveInput|

classdef kWaveThermalSource < kwave.toolbox.kWaveInput

    properties(Dependent=true)
        initialTemperature single {mustBeReal, mustBeFinite}
    end

    properties(Hidden=true)
        initialTemperaturePadded single {mustBeReal, mustBeFinite}
    end

    properties(Constant, Hidden=true)
        requiredProperties = {};
    end

    % Set and get methods.
    methods

        function set.initialTemperature(obj, val)
            obj.kgrid.validateSize(val, VariableName='initialTemperature');
            obj.initialTemperaturePadded = obj.kgrid.assignWithGridPadding(val, 0);
        end

        function set.initialTemperaturePadded(obj, val)
            obj.kgrid.validateSize(val, VariableName='initialTemperaturePadded', IncludePadding=true);
            obj.initialTemperaturePadded = val;
        end

        function initialTemperature = get.initialTemperature(obj)
            initialTemperature = obj.kgrid.returnWithoutGridPadding(obj.initialTemperaturePadded);
        end

    end

end
