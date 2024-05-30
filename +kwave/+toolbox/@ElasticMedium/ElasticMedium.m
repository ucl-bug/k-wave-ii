%% ElasticMedium
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.GridInput
%
% Class used to define the elastic medium properties for a simulation.
%
%% Syntax
%   medium = ElasticMedium(kgrid);
%
%% Description
% This class is used to define the elastic medium properties. The
% constructor takes an object of the |kwave.toolbox.Grid| class which
% defines the grid size. All medium properties can be scalar or have
% the same size as the grid. The |soundSpeedCompression|,
% |soundSpeedShear| and |density| must be defined, while the
% |soundSpeedCompression| and |soundSpeedShear| are used only with the
% Kelvin Voigt model.
%
%% Examples
% Define the grid and medium objects, and assign the sound speed and
% density.
%
%    kgrid = kwave.toolbox.Grid([128, 128], 1e-3);
%    medium = kwave.toolbox.ElasticMedium(kgrid);
%    medium.soundSpeedShear = rand(medium.gridSize);
%    medium.soundSpeedCompression = rand(medium.gridSize);
%    medium.density = rand(medium.gridSize);
%
%% Properties
% * |density| - (single) Mass density [kg/m^2].
% * |soundSpeedCompression| - (single) Compressional sound speed
% * distribution within the acoustic medium [m/s].
% * |soundSpeedShear| - (single) Shear sound speed distribution within
% * the acoustic medium [m/s].
% * |alphaCoeffCompression| - (single) Power law absorption coefficient
% * for compressional waves [dB/(MHz^2 cm)]
% * |alphaCoeffShear| - (single) Power law absorption coefficient for
% * shear waves [dB/(MHz^2 cm)]
%
%% See Also
% * |GridInput|

classdef ElasticMedium < kwave.toolbox.GridInput

    properties
        alphaCoeffCompression single {mustBeReal, mustBePositive, mustBeFinite}
        alphaCoeffShear single {mustBeReal, mustBePositive, mustBeFinite}
    end

    properties(Constant, Hidden=true)
        requiredProperties = {'density', 'soundSpeedCompression', 'soundSpeedShear'};
        gridFields = kwave.toolbox.GridField.createGridFieldsMap([
            kwave.toolbox.GridField('density');
            kwave.toolbox.GridField('soundSpeedCompression');
            kwave.toolbox.GridField('soundSpeedShear');
        ]);
    end

end
