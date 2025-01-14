%% OffGridBoundaryCondition
% *Package:* kwave.toolbox
%
%% Description
%
%% Examples
%
%% Input Arguments
%
%% Properties
%
%% Methods
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

classdef OffGridBoundaryCondition < kwave.toolbox.BoundaryCondition
    
    properties(SetAccess=public,Hidden=false)
        offGrid
        maskBuilder
    end

    properties(SetAccess=private, Hidden=true)
        gridLocations
    end

    % Constructor.
    methods
        function obj=OffGridBoundaryCondition(kgrid,offGrid)
            arguments
                kgrid(1,1) kwave.toolbox.Grid
                offGrid(1,1) kwave.toolbox.OffGrid
            end
            obj@kwave.toolbox.BoundaryCondition(kgrid)

            obj.offGrid=offGrid;
            
            obj.maskBuilder=zeros(obj.kgrid.gridSize);
            obj.gridLocations=zeros(obj.kgrid.totalGridPoints,obj.kgrid.dimensions);
            val=0;
            for j1=1:obj.kgrid.totalGridPoints
                for j2=1:obj.offGrid.gridSize
                    switch obj.kgrid.dimensions
                        case 1
                            gridPoint=[obj.kgrid.x(j1)];
                        case 2
                            gridPoint=[obj.kgrid.x(j1),obj.kgrid.y(j1)];
                        case 3
                            gridPoint=[obj.kgrid.x(j1),obj.kgrid.y(j1),obj.kgrid.z(j1)];
                    end
                    boundaryPoint=obj.offGrid.kgridLocations(j2,:);
                    if(obj.offGrid.ValidGridpointDistance(gridPoint, boundaryPoint,0.01)==1)
                        val=val+1;
                        obj.gridLocations(val,:)=gridPoint;
                        obj.maskBuilder(j1)=1;
                        break
                    end
                end
            end
            obj.gridLocations=obj.gridLocations(1:val,:);
        end
    end
    
    % Override inherited methods.
    methods(Access=public)

         function VariablePadded=applyBoundaryCondition(obj,VariablePadded)
            % Recall the p Values validated by ValidGridPointDistance
            ReducedVariable=VariablePadded(obj.maskPadded==1);
            % For each boundary point compute the pressure
            VariableBoundary=zeros(obj.offGrid.gridSize);
            for j1=1:obj.offGrid.gridSize
                for j2=1:length(obj.gridLocations(:,1))
                        VariableBoundary(j1)=VariableBoundary(j1) + obj.offGrid.BandLimGridPoint(obj.gridLocations(j2,:),obj.offGrid.kgridLocations(j1,:),0.01) * ReducedVariable(j2);
                end
            end
            % Apply the inverse Matrix
            BoundaryChange = obj.offGrid.InvBandLimMatrix * (obj.BoundaryValue-VariableBoundary);
            %Compute the Grid re-weighting
            GridChange=zeros(length(obj.gridLocations(:,1)),1);
            for j1=1:obj.offGrid.gridSize
                for j2=1:length(obj.gridLocations(:,1))
                        GridChange(j2)=GridChange(j2) + obj.offGrid.BandLimGridPoint(obj.gridLocations(j2,:),obj.offGrid.kgridLocations(j1,:),0.01) * BoundaryChange(j1);
                end
            end
            % For each grid Location compute the new pressure
            VariablePadded(obj.maskPadded==1)=VariablePadded(obj.maskPadded==1) + real(GridChange) ;
         end       

    end

    % methods(Access=public)
    % end

end
