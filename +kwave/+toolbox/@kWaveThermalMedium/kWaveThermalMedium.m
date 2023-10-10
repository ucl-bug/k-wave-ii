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
% constructor takes an object of the |kwave.toolbox.kWaveGrid| class which
% defines the grid size. All medium properties can be scalar or have the
% same size as the grid. The |density|, |specificHeat|, and
% |thermalConductivity| must be defined.
%
%% Examples
% Define the grid and medium objects, and assign the thermal properties.
%
%    kgrid = kwave.toolbox.kWaveGrid([128, 128], 1e-3);
%    medium = kwave.toolbox.kWaveThermalMedium(kgrid);
%    medium.density = rand(medium.gridSize);
%    medium.specificHeat = rand(medium.gridSize);
%    medium.thermalConductivity = rand(medium.gridSize);
%
%% Properties
% * |density| - (numeric) Mass density [kg/m^2].
% * |diffusionReference| - (numeric) Reference diffusion coefficient used
%   in the k-space correction term [m^2/s]. Automatically defined in
%   ThermalSolver if not defined by the user.
% * |specificHeat| - (numeric) Specific heat capacity at constant pressure
%   [J/kg/K].
% * |thermalConductivity| - (numeric) Thermal conductivity [W/m/K].
%
%% See Also
% * |kWaveInput|

classdef kWaveThermalMedium < kwave.toolbox.kWaveInput

    properties
        diffusionReference {mustBeReal, mustBeFinite}
    end

    properties(Constant, Hidden=true)
        requiredProperties = {'density', 'specificHeat', 'thermalConductivity'};
        gridFields = kwave.toolbox.GridField.createGridFieldsMap([
            kwave.toolbox.GridField('density');
            kwave.toolbox.GridField('specificHeat');
            kwave.toolbox.GridField('thermalConductivity')
        ]);
    end

end
