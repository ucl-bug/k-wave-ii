%% setBoundaryCondition
% *Class:* kwave.toolbox.AcousticSolver
% *Package:* kwave.toolbox
%
%% Syntax
%
%% Description
%
%% Input Arguments
%
%
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

function setPressureBoundaryCondition(obj,PressureBoundaryCondition)

arguments
    obj
    PressureBoundaryCondition kwave.toolbox.BoundaryCondition
end

if max(size(PressureBoundaryCondition.maskPadded))~=1
    switch obj.kgrid.dimensions
        case 1
            assert(PressureBoundaryCondition.maskPadded(1)==0 && PressureBoundaryCondition.maskPadded(end)==0) 
        case 2
            assert(min(PressureBoundaryCondition.maskPadded(1,:)==zeros(1,obj.kgridPadded.Ny))) 
            assert(min(PressureBoundaryCondition.maskPadded(end,:)==zeros(1,obj.kgridPadded.Ny)))
            assert(min(PressureBoundaryCondition.maskPadded(:,1)==zeros(obj.kgridPadded.Nx,1)) )
            assert(min(PressureBoundaryCondition.maskPadded(:,end)==zeros(obj.kgridPadded.Nx,1)))
        case 3
            assert(PressureBoundaryCondition.maskPadded(1,:,:)==zeros(1,obj.kgridPadded.Ny,obj.kgridPadded.Nz) && PressureBoundaryCondition.maskPadded(end,:,:)==zeros(1,obj.kgridPadded.Ny,obj.kgridPadded.Nz))
            assert(PressureBoundaryCondition.maskPadded(:,1,:)==zeros(obj.kgridPadded.Nx,1,obj.kgridPadded.Nz) && PressureBoundaryCondition.maskPadded(:,end,:)==zeros(obj.kgridPadded.Nx,1,obj.kgridPadded.Nz))
            assert(PressureBoundaryCondition.maskPadded(:,:,1)==zeros(obj.kgridPadded.Nx,obj.kgridPadded.Ny,1) && PressureBoundaryCondition.maskPadded(:,:,end)==zeros(obj.kgridPadded.Nx,obj.kgridPadded.Ny,1))
    end
    obj.PressureBoundCond = 'on';
    obj.PressureBoundaryCondition=PressureBoundaryCondition;
else
    error('AcousticSolver:BoundaryCondition:MaskError', 'Mask must be given as the size of the computational Grid, and be 0 on the edges')
end
