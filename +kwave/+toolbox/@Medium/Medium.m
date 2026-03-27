%% Medium
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.GridInput
%
% Class used to define the acoustic medium properties for a simulation.
%
%% Syntax
%   medium = Medium(kgrid);
%
%% Description
% This class is used to define the acoustic medium properties. The
% constructor takes an object of the |kwave.toolbox.Grid| class which
% defines the grid size. All medium properties can be scalar or have the
% same size as the grid with the exception of |alphaPower| and
% |soundSpeedReference|, which must be scalar. The |soundSpeed| and
% |density| must be defined.
%
%% Examples
% Define the grid and medium objects, and assign the sound speed and
% density.
%
%    kgrid = kwave.toolbox.Grid([128, 128], 1e-3);
%    medium = kwave.toolbox.AcousticMedium(kgrid);
%    medium.soundSpeed = rand(medium.gridSize);
%    medium.density = rand(medium.gridSize);
%    medium.specificHeat = rand(medium.gridSize);
%    medium.thermalConductivity = rand(medium.gridSize);
%
%% Properties
% * |soundSpeed| and |soundSpeedPadded|- (single) Compressional sound speed [m/s].
% * |soundSpeedReference| - (single) Reference compressional sound speed
%   used in the k-space correction [m/s]. Automatically defined in
%   |kWaveAcoustic| if not defined by the user.
% * |density| and |densityPadded|- (single) Mass density [kg/m^2].
% * |absorptionCoeff| and |absorptionCoeffPadded|- (single) Power law attenuation coefficient
%   [dB/(MHz^y cm)].
% * |absorptionPower| - (single) Power law attenuation power.
% * |BonA| and |BonAPadded|- (single) Parameter of nonlinearity.
% * |diffusionReference| - (numeric) Reference diffusion coefficient used
%   in the k-space correction term [m^2/s]. Automatically defined in
%   |ThermalSolver| if not defined by the user.
% * |specificHeat| and |specificHeatPadded|- (numeric) Specific heat capacity at constant pressure
%   [J/kg/K].
% * |thermalConductivity| and |thermalConductivityPadded|- (numeric) Thermal conductivity [W/m/K].
%
%% See Also
% * |GridInput|

classdef Medium < kwave.toolbox.GridInput

    properties
        soundSpeedReference single {mustBeReal, mustBePositive, mustBeFinite}
        diffusionReference {mustBeReal, mustBeFinite}
        materialTable (:,7) single {mustBeReal, mustBeNonnegative, mustBeFinite} =  kwave.toolbox.BuildMaterialTable()
    end

    properties(Constant, Hidden=false)
        requiredProperties = {'materialIDGrid'}; %'soundSpeed', 'density', 'specificHeat', 'thermalConductivity'};
        gridFields = kwave.toolbox.GridField.createGridFieldsMap([
            kwave.toolbox.GridField('materialIDGrid')

            ]);
    end

    methods
        soundSpeed = soundSpeedPadded(obj)
        density = densityPadded(obj)
        absorptionCoeff = absorptionCoeffPadded(obj)
        absorptionPower = absorptionPower(obj)
        BonA = BonAPadded(obj)
        specificHeat = specificHeatPadded(obj)
        thermalConductivity = thermalConductivityPadded(obj)
        soundSpeed = soundSpeed(obj)
        density = density(obj)
        absorptionCoeff = absorptionCoeff(obj)
        BonA = BonA(obj)
        specificHeat = specificHeat(obj)
        thermalConductivity = thermalConductivity(obj)
    end
end
