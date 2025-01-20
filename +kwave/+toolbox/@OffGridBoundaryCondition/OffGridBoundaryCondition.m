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
        accuracy
    end

    properties(SetAccess=private, Hidden=true)
        gridLocations
        
    end

    % Constructor.
    methods
        function obj=OffGridBoundaryCondition(kgrid,offGrid,accuracy)
            arguments
                kgrid(1,1) kwave.toolbox.Grid
                offGrid(1,1) kwave.toolbox.OffGrid
                accuracy(1,1) {mustBeNumeric,mustBePositive,mustBeFinite,mustBeReal}
            end
            obj@kwave.toolbox.BoundaryCondition(kgrid)
            obj.accuracy=accuracy;
            obj.offGrid=offGrid;

            obj.maskBuilder=zeros(obj.kgrid.gridSize);
            obj.gridLocations=zeros(obj.kgrid.totalGridPoints,obj.kgrid.dimensions);
            for j1=1:obj.kgrid.totalGridPoints
                switch obj.kgrid.dimensions
                    case 1
                        gridPoint=[obj.kgrid.x(j1)/obj.kgrid.gridSpacing(1)];
                    case 2
                        gridPoint=[obj.kgrid.x(j1)/obj.kgrid.gridSpacing(1),obj.kgrid.y(j1)/obj.kgrid.gridSpacing(2)];
                    case 3
                        gridPoint=[obj.kgrid.x(j1)/obj.kgrid.gridSpacing(1),obj.kgrid.y(j1)/obj.kgrid.gridSpacing(2),obj.kgrid.z(j1)/obj.kgrid.gridSpacing(3)];
                end
                obj.gridLocations(j1,:)=gridPoint;
            end
            Dists=sum(obj.offGrid.ValidGridpointDistance(obj.gridLocations, obj.offGrid.gridLocations,obj.accuracy),1);
            obj.maskBuilder(Dists>=1)=1;
            obj.gridLocations=obj.gridLocations(Dists>=1,:);
        end
    end

    % Override inherited methods.
    methods(Access=public)

        function VariablePadded=applyBoundaryCondition(obj,VariablePadded)
            % tol=1;
            % reps=0;

            % Recall the p Values validated by ValidGridPointDistance
            ReducedVariable=VariablePadded(obj.maskPadded==1);
            % For each boundary point compute the pressure
            VariableBoundary=zeros(1,obj.offGrid.gridSize);
            VariableBoundary=VariableBoundary + sum(obj.offGrid.BandLimGrid(obj.gridLocations,obj.offGrid.gridLocations,obj.accuracy).' .* ReducedVariable,1);

            % while tol>1e-8 || reps <= 20

                % Apply the inverse Matrix
                BoundaryChange = obj.offGrid.InvBandLimMatrix * (obj.BoundaryValue-VariableBoundary.');
                %Compute the Grid re-weighting
                GridChange=zeros(length(obj.gridLocations(:,1)),1);
                GridChange=GridChange + sum( obj.offGrid.BandLimGrid(obj.gridLocations,obj.offGrid.gridLocations,obj.accuracy) .* BoundaryChange,1).';
                % For each grid Location compute the new pressure
                VariablePadded(obj.maskPadded==1)=ReducedVariable + real(GridChange) ;
                % ReducedVariable=ReducedVariable + real(GridChange);

                % VariableBoundary=zeros(1,obj.offGrid.gridSize);
                % VariableBoundary=VariableBoundary + sum(obj.offGrid.BandLimGrid(obj.gridLocations,obj.offGrid.gridLocations,obj.accuracy).' .* ReducedVariable,1);

                % tol=max(max(abs(obj.BoundaryValue-VariableBoundary)));
                % reps=reps+1;
            % end
        end

    end

    % methods(Access=public)
    % end

end
