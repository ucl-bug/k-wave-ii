%% absorptionPower
% *Class:* kwave.toolbox.Medium
% *Package:* kwave.toolbox
%
% Sets and Calls the abosrptionPower scalar variable.
%
%% Syntax
%   absorptionPower(obj)
%
%% Description
% sets and recalls the absorption Power y spatial distribution according to the materialIDGrid,
% and the MaterialTable given as part of the medium. 
% 
% This is performed by generating the padded Density and removing the PML.
% The resulting values are then averaged across the grid to produce a
% scalar value, this is by the arithmatic mean. The absorption coefficients
% are not homogonised like this.
%
% Alternative averaging including averaging omega^y for a fixed central
% frequency acros the grid, or according to the total absortion alpha =
% alpha_0 omega^y such that higher absorbing regions are weighted higher.

% Copyright (C) 2025- The k-Wave Authors.
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

function sS=absorptionPower(obj)
arguments
    obj
end
if ~isscalar(obj.materialIDGridPadded)

    disp('absorptionPower value must be scalar, setting to averaged')
    V=obj.materialIDGridPadded;

    switch obj.kgrid.dimensions
        case 1
            V2=V(obj.kgrid.gridPadding(1)+1:end-obj.kgrid.gridPadding(1));
        case 2
            V2=V(obj.kgrid.gridPadding(1)+1:end-obj.kgrid.gridPadding(1), obj.kgrid.gridPadding(2)+1:end-obj.kgrid.gridPadding(2));
        case 3
            V2=V(obj.kgrid.gridPadding(1)+1:end-obj.kgrid.gridPadding(1), obj.kgrid.gridPadding(2)+1:end-obj.kgrid.gridPadding(2), obj.kgrid.gridPadding(3)+1:end-obj.kgrid.gridPadding(3));
    end

    sS=mean(obj.materialTable(V2,4));

else
    sS=obj.materialTable(obj.materialIDGridPadded,4);
end