%% subsref
% *Class:* kwave.toolbox.kWaveInput
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
% with the virtual properties of the |kwave.toolbox.kWaveInput| class. When
% users query one of these virtual properties, the method retrieves its
% internally stored padded counterpart and returns the non-padded view to
% the user, aligning with the virtual property's concept.
%
% If the targeted property or method isn't one of the virtual properties,
% the method  falls back to MATLAB's default |subsref| operation.
%
%% Input Arguments
% * |obj| - (kwave.toolbox.kWaveInput) Instance of the kWaveInput class.
% * |S| - (struct) MATLAB structure specifying the target property or
%   method and type of referencing. 
%
%% Output Arguments
% * |value| - (various) The retrieved data or method output. If the target
%   is a virtual property, it will be the non-padded representation of the
%   underlying data.

function value = subsref(obj, S)

if (S(1).type == '.') && (obj.gridFields.isKey(S(1).subs))
    propertyPaddedName = strcat(S(1).subs, 'Padded');
    value = obj.kgrid.returnWithoutGridPadding(obj.(propertyPaddedName));
    return;
end

if (nargout == 0) && ismethod(obj, S(1).subs)
    builtin('subsref', obj, S);
    return;
else
    value = builtin('subsref', obj, S);
end
