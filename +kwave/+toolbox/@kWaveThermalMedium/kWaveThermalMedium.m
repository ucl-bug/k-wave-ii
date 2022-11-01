%% kWaveThermalMedium
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.kWaveInput
%
% Class used to define the thermal medium properties for a simulation.
%
%% Syntax
%   kgrid = kWaveGrid([128, 128], 1e-3);
%   medium = kWaveThermalMedium(kgrid);
%   medium.density = rand(medium.gridSize);
%
%% Description
% This class is used to define the thermal medium properties. The
% constructor takes an object of the |kWaveGrid| class which defines the
% grid size. All medium properties can be scalar or have the same size as
% the grid. The |density|, |specificHeat|, and |thermalConductivity| must
% be defined.
%
% Note: Internally, the medium properties that are allowed to be
% heterogeneous are stored including the grid padding defined by
% |kgrid.gridPadding|. The set and get methods automatically add and remove
% the grid padding. The padded variants can be accessed via the hidden
% properties |densityPadded|, etc.
%
%% Examples
% Define the grid and medium objects, and assign the thermal properties.
%
%    kgrid = kwave.toolbox.kWaveGrid([128, 128], 1e-3);
%    medium = kwave.toolbox.kWaveAcousticMedium(kgrid);
%    medium.density = rand(medium.gridSize);
%    medium.specificHeat = rand(medium.gridSize);
%    medium.thermalConductivity = rand(medium.gridSize);
%
%% Properties
% * |density| - (single) Mass density [kg/m^2].
% * |specificHeat| - (single) Mass density [kg/m^2].
% * |thermalConductivity| - (single) Mass density [kg/m^2].
%
%% See Also
% * |kWaveInput|

classdef kWaveThermalMedium < kwave.toolbox.kWaveInput

    properties(Hidden=true)
        densityPadded single
        specificHeatPadded single
        thermalConductivityPadded single
    end

    properties(Dependent=true)
        density single
        specificHeat single
        thermalConductivity single
    end

    properties(Constant, Hidden=true)
        requiredProperties = {'density', 'specificHeat', 'thermalConductivity'};
    end

    % Set and get methods.
    methods
        
        function set.specificHeat(obj, val)
            obj.kgrid.validateSize(val, VariableName='specificHeat');
            obj.specificHeatPadded = obj.kgrid.assignWithGridPadding(val);
        end

        function set.specificHeatPadded(obj, val)
            obj.kgrid.validateSize(val, VariableName='specificHeatPadded', IncludePadding=true);
            obj.specificHeatPadded = val;
        end

        function specificHeat = get.specificHeat(obj)
            specificHeat = obj.kgrid.returnWithoutGridPadding(obj.specificHeatPadded);
        end        

        function set.density(obj, val)
            obj.kgrid.validateSize(val, VariableName='density');
            obj.densityPadded = obj.kgrid.assignWithGridPadding(val);
        end

        function set.densityPadded(obj, val)
            obj.kgrid.validateSize(val, VariableName='densityPadded', IncludePadding=true);
            obj.densityPadded = val;
        end

        function density = get.density(obj)
            density = obj.kgrid.returnWithoutGridPadding(obj.densityPadded);
        end            

        function set.thermalConductivity(obj, val)
            obj.kgrid.validateSize(val, VariableName='thermalConductivity');
            obj.thermalConductivityPadded = obj.kgrid.assignWithGridPadding(val);
        end

        function set.thermalConductivityPadded(obj, val)
            obj.kgrid.validateSize(val, VariableName='thermalConductivityPadded', IncludePadding=true);
            obj.thermalConductivityPadded = val;
        end

        function thermalConductivity = get.thermalConductivity(obj)
            thermalConductivity = obj.kgrid.returnWithoutGridPadding(obj.thermalConductivityPadded);
        end            
        
    end
    
end
