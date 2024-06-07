%% GridFieldType
% *Package:* kwave.toolbox
%
%% Description
% Enumerated type for defining different grid field types. These are used
% with the |GridField| class for size validation.
%
%% Enumeration Members
% * |ScalarField| - Scalar field the same size as the grid.
% * |VectorField| - Vector field where the first three dimensions match the
%   size of the grid, and the vector components are stored in the 4th
%   dimension.
% * |SymTensorField| - Symetric tensor field where the first three 
%   dimensions match the size of the grid, and the vector components are 
%   stored in the 4th dimension.
% * |VectorX| - 1D vector oriented in the x-direction.
% * |VectorY| - 1D vector oriented in the y-direction.
% * |VectorZ| - 1D vector oriented in the z-direction.
%% See Also
% * |kwave.toolbox.Grid|
% * |kwave.toolbox.GridField|
% * |kwave.toolbox.GridInput|

classdef GridFieldType
    enumeration
        ScalarField
        VectorField
        SymTensorField
        VectorX
        VectorY
        VectorZ
    end
end
