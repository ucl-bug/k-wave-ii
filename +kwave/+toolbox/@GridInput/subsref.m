%% The subsref method
% *Class:* kwave.toolbox.GridInput
% *Package:* kwave.toolbox
%
% Overloaded reference method to manage interactions with virtual
% properties.
%
%% Syntax
%   value = subsref(obj, S);
%
%% Description
% The |subsref| method has been overloaded to facilitate user interactions
% with the virtual properties of the |kwave.toolbox.GridInput| class. When
% users query one of these virtual properties, the method retrieves its
% internally stored padded counterpart and returns the non-padded view to
% the user, aligning with the virtual property's concept.
%
% If the targeted property or method isn't one of the virtual properties,
% the method  falls back to MATLAB's default |subsref| operation.
%
%% Input Arguments
% * |obj| - (kwave.toolbox.GridInput) Instance of the GridInput class.
% * |S| - (struct) MATLAB structure specifying the target property or
%   method and type of referencing. 
%
%% Output Arguments
% * |value| - (various) The retrieved data or method output. If the target
%   is a virtual property, it will be the non-padded representation of the
%   underlying data.

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

function varargout = subsref(obj, S)

if (S(1).type == '.') && (obj.gridFields.isKey(S(1).subs))

    propertyPaddedName = strcat(S(1).subs, 'Padded');
    varargout{1} = obj.kgrid.returnWithoutGridPadding(obj.(propertyPaddedName));

    % If there are any more subreferences, apply them.
    if length(S) > 1
        S2 = S(2:end);
        varargout{1} = builtin('subsref', varargout{1}, S2);
    end

else
    [varargout{1:nargout}] = builtin('subsref', obj, S);
end
