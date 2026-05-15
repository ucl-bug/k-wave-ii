%% AcousticSource
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.GridInput
%
% Class used to define acoustic sources.
%
%% Syntax
%   source = AcousticSource(kgrid);
%
%% Description
% This class is used to define the acoustic source terms (which includes
% initial conditions). The constructor takes an object of the
% |kwave.toolbox.Grid| class, which defines the grid size.
%
%% Examples
% Define the grid and source objects, and assign the initial pressure.
%
%    kgrid = kwave.toolbox.Grid([128, 128], 1e-3);
%    source = kwave.toolbox.AcousticSource(kgrid);
%    source.initialPressure = rand(source.gridSize);
%
%% Required Properties
% * |initialPressure| - Initial acoustic pressure distribution [Pa].
%
%% Optional Properties
% * |initialVelocity| - Initial acoustic particle velocity distribution [m/s].
%                       If this is not defined, it is assumed to be zero.
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

classdef AcousticSource < kwave.toolbox.GridInput

    properties(Constant, Hidden=true)

        requiredProperties = {'initialPressure'};

        gridFields = kwave.toolbox.GridField.createGridFieldsMap([
            kwave.toolbox.GridField('initialPressure', Attributes={'real', 'finite'})
            kwave.toolbox.GridField('initialVelocity', Attributes={'real', 'finite'}, Type=kwave.toolbox.GridFieldType.VectorField)
        ]);

    end

end
