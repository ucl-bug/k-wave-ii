%% subsasgn
% *Class:* kwave.toolbox.GridInput
% *Package:* kwave.toolbox
%
% Overloaded assignment method to manage interactions with virtual
% properties.
%
%% Syntax
%   obj = subsasgn(obj, S, value);
%
%% Description
% The |subsasgn| method has been overloaded to enhance interactions with
% the virtual properties of the |kwave.toolbox.GridInput| class. These
% virtual properties present users with an intuitive view of the non-padded
% grid, while internally the actual stored properties include the grid
% padding essential for k-Wave simulations.
%
% When users assign a value to one of these virtual properties, this method
% validates the data, ensures it aligns with the grid size using the
% Grid object, and then maps the assignment to its internally stored,
% padded counterpart. If the targeted property is not a virtual property,
% the method falls back to MATLAB's default |subsasgn| operation.
%
%% Input Arguments
% * |obj| - (kwave.toolbox.GridInput) Instance of the GridInput class.
% * |S| - (struct) MATLAB structure specifying the target property and type
%   of assignment. 
% * |value| - (various) The data to be assigned. Its attributes are
%   validated if the target is a virtual property.
%
%% Output Arguments
% * |obj| - (kwave.toolbox.GridInput) The GridInput class instance,
%   updated with the new assignment, whether it was to a virtual or a
%   standard property.

function obj = subsasgn(obj, S, value)

if (S(1).type == '.') && (obj.gridFields.isKey(S(1).subs))

    % If there's more than a single assignment, it means that something is
    % being done to the referenced variable. So we first do it and then
    % assign the value.
    if length(S) > 1 
        unpaddedArray = obj.subsref(S(1));
        S2 = S(2:end);
        value = builtin('subsasgn', unpaddedArray, S2, value);
    end

    % Assign the value.
    propertyDetails = obj.gridFields(S(1).subs);
    propertyPaddedName = strcat(S(1).subs, 'Padded');
    validateattributes(value, propertyDetails.classes, propertyDetails.attributes, '', S(1).subs);
    obj.kgrid.validateSize(value, VariableName=S(1).subs, Type=propertyDetails.type);
    obj.(propertyPaddedName) = obj.kgrid.assignWithGridPadding(value);

else
    obj = builtin('subsasgn', obj, S, value);
end
