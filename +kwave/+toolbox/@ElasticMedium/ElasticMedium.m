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
% Kelvin-Voigt model.
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

% Copyright (C) 2024- The k-Wave Authors.
%
% This file is part of k-Wave-II (http://www.k-wave.org). k-Wave-II is free
% software: you can redistribute it and/or modify it under the terms of the
% GNU Lesser General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any
% later version.
%
% k-Wave-II is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
% License for more details.
%
% You should have received a copy of the GNU Lesser General Public License
% along with k-Wave-II. If not, see <http://www.gnu.org/licenses/>.

classdef ElasticMedium < kwave.toolbox.GridInput

    properties(Constant, Hidden=true)
        requiredProperties = {'density', 'soundSpeedCompression', 'soundSpeedShear'};
        gridFields = kwave.toolbox.GridField.createGridFieldsMap([
            kwave.toolbox.GridField('density');
            kwave.toolbox.GridField('soundSpeedCompression');
            kwave.toolbox.GridField('soundSpeedShear');
            kwave.toolbox.GridField('alphaCoeffCompression');
            kwave.toolbox.GridField('alphaCoeffShear');
        ]);
    end

end
