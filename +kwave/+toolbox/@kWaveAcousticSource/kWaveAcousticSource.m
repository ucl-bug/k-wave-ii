%% kWaveAcousticSource
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.kWaveInput
%
% Class used to define the acoustic sources for a simulation.
%
%% Syntax
%   source = kWaveAcousticSource(kgrid);
%
%% Description
% This class is used to define the acoustic source terms. The constructor
% takes an object of the kWaveGrid class which defines the grid size.
% Source matrices must match the grid size defined by kgrid. Inputs are
% cast to single precision.
%
%% Examples
% Define the grid and source objects, and assign the initial pressure.
%
%    kgrid = kwave.toolbox.kWaveGrid([128, 128], 1e-3);
%    source = kwave.toolbox.kWaveAcousticSource(kgrid);
%    source.initialPressure = rand(source.gridSize);
%
%% Properties
% * |initialPressure| - (single) Initial pressure distribution [Pa]. This
%   assumes the initial particle velocity is zero, which is a equivalent to
%   a photoacoustic source under the conditions of stress confinement.
%
%% See Also
% * |kWaveInput|

classdef kWaveAcousticSource < kwave.toolbox.kWaveInput

    properties(Dependent=true)
        initialPressure single
    end

    properties(Hidden=true)
        initialPressurePadded single
    end

    properties(Constant, Hidden=true)
        requiredProperties = {};
    end

    % Set and get methods.
    methods

        function set.initialPressure(obj, val)
            obj.kgrid.validateSize(val, VariableName='initialPressure');
            obj.initialPressurePadded = obj.kgrid.assignWithGridPadding(val, 0);
        end

        function set.initialPressurePadded(obj, val)
            obj.kgrid.validateSize(val, VariableName='initialPressurePadded', IncludePadding=true);
            obj.initialPressurePadded = val;
        end

        function initialPressure = get.initialPressure(obj)
            initialPressure = obj.kgrid.returnWithoutGridPadding(obj.initialPressurePadded);
        end

    end

end
