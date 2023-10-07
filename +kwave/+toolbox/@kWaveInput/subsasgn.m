%% subsasgn
% *Class:* kwave.toolbox.kWaveInput
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
% the virtual properties of the |kwave.toolbox.kWaveInput| class. These
% virtual properties present users with an intuitive view of the non-padded
% grid, while internally the actual stored properties include the grid
% padding essential for k-Wave simulations.
%
% When users assign a value to one of these virtual properties, this method
% validates the data, ensures it aligns with the grid size using the
% kWaveGrid object, and then maps the assignment to its internally stored,
% padded counterpart. If the targeted property is not a virtual property,
% the method falls back to MATLAB's default |subsasgn| operation.
%
%% Input Arguments
% * |obj| - (kwave.toolbox.kWaveInput) Instance of the kWaveInput class.
% * |S| - (struct) MATLAB structure specifying the target property and type
%   of assignment. 
% * |value| - (various) The data to be assigned. Its attributes are
%   validated if the target is a virtual property.
%
%% Output Arguments
% * |obj| - (kwave.toolbox.kWaveInput) The kWaveInput class instance,
%   updated with the new assignment, whether it was to a virtual or a standard property.

function obj = subsasgn(obj, S, value)

if (S(1).type == '.') && (obj.gridFields.isKey(S(1).subs))
    propertyDetails = obj.gridFields(S(1).subs);
    propertyPaddedName = strcat(S(1).subs, 'Padded');
    validateattributes(value, propertyDetails.classes, propertyDetails.attributes, '', S(1).subs);
    obj.kgrid.validateSize(value, VariableName=S(1).subs);
    obj.(propertyPaddedName) = obj.kgrid.assignWithGridPadding(value);
    return;
end

obj = builtin('subsasgn', obj, S, value);
