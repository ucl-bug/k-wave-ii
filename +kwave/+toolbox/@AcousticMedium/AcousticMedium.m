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
%    medium.absorptionCoeff = rand(medium.gridSize);
%    medium.absorptionPower = rand();
%
%% Properties
% 
% * |soundSpeed| - (single) Compressional sound speed [m/s].
% * |soundSpeedReference| - (single) Reference compressional sound speed
%   used in the k-space correction [m/s]. Automatically defined in
%   kWaveAcoustic if not defined by the user.
% * |density| - (single) Mass density [kg/m^2].
% * |absorptionCoeff| - (single) Power law attenuation coefficient
%   [dB/(MHz^y cm)]. 
% * |absorptionPower| - (single scalar) Power law attenuation power.
% * |BonA| - (single) Parameter of nonlinearity.
%
% In order to model absorption both absorptionCoeff, and absorptionPower
% must be defined, and solver.absorptionType must be set for the acoustic
% solver
%
%% See Also
% 
% * |GridInput|
% * |AcousticSolver|

classdef AcousticMedium < kwave.toolbox.GridInput

    properties
        soundSpeedReference single {mustBeReal, mustBePositive, mustBeFinite}
        absorptionPower single {mustBeReal, mustBeFinite};
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
