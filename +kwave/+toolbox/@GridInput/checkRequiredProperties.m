%% Check Required Properties
% *Class:* kwave.toolbox.GridInput
% *Package:* kwave.toolbox
%
% Validates that the essential properties of the input object are defined.
%
%% Syntax
%   checkRequiredProperties(obj)
%
%% Description
% Ensures that all critical properties, as specified in the
% |obj.requiredProperties| cell array, are defined and not empty. This
% method is intended to be called by the |kWaveSolver| constructor to
% guarantee that the input object is in a valid state before proceeding
% with a simulation. If any required property is not defined, the
% |GridInput:missingInput| error is thrown, informing the user of the
% missing property.
%
%% Input Arguments
% * |obj| - (kwave.toolbox.GridInput) An instance of the
%   |kwave.toolbox.GridInput| class. This object's |requiredProperties|
%   attribute determines which properties must be checked.

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

function checkRequiredProperties(obj)

for ind = 1:length(obj.requiredProperties)
    if isempty(obj.subsref(struct('type', '.', 'subs', obj.requiredProperties{ind})))
        kwave.toolbox.Logger.error('GridInput:missingInput', ['The property ' obj.requiredProperties{ind} ' must be defined.']);
    end
end
