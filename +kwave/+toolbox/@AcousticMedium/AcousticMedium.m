%% AcousticMedium
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.GridInput
%
% Class used to define the acoustic medium properties for a simulation.
%
%% Syntax
%   medium = AcousticMedium(kgrid);
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
%
%% Properties
% * |soundSpeed| - (single) Compressional sound speed [m/s].
% * |soundSpeedReference| - (single) Reference compressional sound speed
%   used in the k-space correction [m/s]. Automatically defined in
%   kWaveAcoustic if not defined by the user.
% * |density| - (single) Mass density [kg/m^2].
% * |absorptionCoeff| - (single) Power law attenuation coefficient
%   [dB/(MHz^y cm)]. 
% * |absorptionPower| - (single) Power law attenuation power.
% * |BonA| - (single) Parameter of nonlinearity.
% * |absorptionType| - string, 'noAbsorption', 'noDispersion', turns off tau and eta respectively 
%% See Also
% * |GridInput|

classdef AcousticMedium < kwave.toolbox.GridInput

    properties
        soundSpeedReference single {mustBeReal, mustBePositive, mustBeFinite}
        absorptionPower single {mustBeReal, mustBeFinite} = 0
        absorptionType string = 'noType'
    end

    properties(Constant, Hidden=true)
        requiredProperties = {'soundSpeed', 'density'};
        gridFields = kwave.toolbox.GridField.createGridFieldsMap([
            kwave.toolbox.GridField('soundSpeed');
            kwave.toolbox.GridField('density');
            kwave.toolbox.GridField('absorptionCoeff');
            kwave.toolbox.GridField('BonA')
        
        ]);
    end

end
