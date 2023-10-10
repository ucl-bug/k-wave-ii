%% kWaveAcousticMedium
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.kWaveInput
%
% Class used to define the acoustic medium properties for a simulation.
%
%% Syntax
%   medium = kWaveAcousticMedium(kgrid);
%
%% Description
% This class is used to define the acoustic medium properties. The
% constructor takes an object of the |kwave.toolbox.kWaveGrid| class which
% defines the grid size. All medium properties can be scalar or have the
% same size as the grid with the exception of |alphaPower| and
% |soundSpeedReference|, which must be scalar. The |soundSpeed| and
% |density| must be defined.
%
%% Examples
% Define the grid and medium objects, and assign the sound speed and
% density.
%
%    kgrid = kwave.toolbox.kWaveGrid([128, 128], 1e-3);
%    medium = kwave.toolbox.kWaveAcousticMedium(kgrid);
%    medium.soundSpeed = rand(medium.gridSize);
%    medium.density = rand(medium.gridSize);
%
%% Properties
% * |soundSpeed| - (single) Compressional sound speed [m/s].
% * |soundSpeedReference| - (single) Reference compressional sound speed
%   used in the k-space correction [m/s]. Automatically defined in
%   kWaveAcoustic if not defined by the user.
% * |density| - (single) Mass density [kg/m^2].
% * |alphaCoeff| - (single) Power law attenuation coefficient
%   [dB/(MHz^y cm)]. 
% * |alphaPower| - (single) Power law attenuation power.
% * |BonA| - (single) Parameter of nonlinearity.
%
%% See Also
% * |kWaveInput|

classdef kWaveAcousticMedium < kwave.toolbox.kWaveInput

    properties
        soundSpeedReference single {mustBeReal, mustBePositive, mustBeFinite}
        alphaPower single {mustBeReal, mustBeFinite}
    end

    properties(Constant, Hidden=true)
        requiredProperties = {'soundSpeed', 'density'};
        gridFields = kwave.toolbox.GridField.createGridFieldsMap([
            kwave.toolbox.GridField('soundSpeed');
            kwave.toolbox.GridField('density');
            kwave.toolbox.GridField('alphaCoeff');
            kwave.toolbox.GridField('BonA')
        ]);
    end

end
