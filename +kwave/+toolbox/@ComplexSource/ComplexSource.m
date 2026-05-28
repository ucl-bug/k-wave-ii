%% ComplexSource
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.GridInput
%
% Class used to define complex sources for a simulation.
%
%% Syntax
%   source = ComplexSource(kgrid);
%
%% Description
% This class is used to define complex valued source terms. The constructor
% takes an object of the |kwave.toolbox.Grid| class which defines the grid
% size. Source matrices must match the grid size defined by |kgrid|.
%
%% Examples
% Define the grid and source objects, and assign the source field.
%
%    kgrid = kwave.toolbox.Grid([128, 128], 1e-3);
%    source = kwave.toolbox.ComplexSource(kgrid);
%    source.sourceField = rand(source.gridSize) + 1i * rand(source.gridSize);
%
%% Properties
% * |sourceField| - (numeric) Complex source field distribution [Pa +
%   i*rad].
% * |sourceFieldMagnitude| - (numeric) Magnitude of the complex source
%   field [Pa].
% * |sourceFieldPhase| - (numeric) Phase of the complex source field
%   [radians].
%
%% See Also
% * |kwave.toolbox.GridInput|

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

classdef ComplexSource < kwave.toolbox.GridInput

    properties(Dependent=true)
        sourceFieldMagnitude
        sourceFieldPhase
    end

    properties(Constant, Hidden=true)
        requiredProperties = {};
        gridFields = kwave.toolbox.GridField.createGridFieldsMap([
            kwave.toolbox.GridField('sourceField', Attributes={'finite'})
        ]);
    end

    % Properties
    methods

        % Returns the magnitude of the source field
        function sourceFieldMagnitude = get.sourceFieldMagnitude(obj)
            sourceFieldMagnitude = abs(obj.subsref(struct('type', '.', 'subs', 'sourceField')));
        end

        % Returns the phase of the source field
        function sourceFieldPhase = get.sourceFieldPhase(obj)
            sourceFieldPhase = angle(obj.subsref(struct('type', '.', 'subs', 'sourceField')));
        end

    end

end
