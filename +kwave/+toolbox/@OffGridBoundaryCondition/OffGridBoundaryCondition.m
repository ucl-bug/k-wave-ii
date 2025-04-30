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
        function obj=OffGridBoundaryCondition(kgrid,offGrid,options)
            arguments
                kgrid(1,1) kwave.toolbox.Grid
                offGrid(1,1) kwave.toolbox.OffGrid
                options.accuracy(1,1) {mustBeNumeric,mustBePositive,mustBeFinite,mustBeReal} =0.01;
                options.staggering(1,:) char {mustBeMember(options.staggering, {'none', 'forward', 'backward'})} = 'none'
            end
            obj@kwave.toolbox.BoundaryCondition(kgrid)
            obj.accuracy=options.accuracy;
            obj.staggering=options.staggering;
            obj.offGrid=offGrid;

            obj.maskBuilder=zeros(obj.kgrid.gridSize);
            obj.gridLocations=zeros(obj.kgrid.totalGridPoints,obj.kgrid.dimensions);

            if strcmp(obj.staggering,'none')
                shift= 0;
            elseif strcmp(obj.staggering,'forward')
                shift= +1/2;
            else
                shift=-1/2;
            end
            obj.offGrid.gridLocations = obj.offGrid.gridLocations - shift;
            
            for j1=1:obj.kgrid.totalGridPoints
                switch obj.kgrid.dimensions
                    case 1
                        gridPoint=obj.kgrid.x(j1)/obj.kgrid.gridSpacing(1);
                    case 2
                        gridPoint=[obj.kgrid.x(j1)/obj.kgrid.gridSpacing(1),obj.kgrid.y(j1)/obj.kgrid.gridSpacing(2)];
                    case 3
                        gridPoint=[obj.kgrid.x(j1)/obj.kgrid.gridSpacing(1),obj.kgrid.y(j1)/obj.kgrid.gridSpacing(2),obj.kgrid.z(j1)/obj.kgrid.gridSpacing(3)];
                end
                obj.gridLocations(j1,:)=gridPoint;
            end
            Dists=sum(obj.offGrid.ValidGridpointDistance(obj.offGrid.gridLocations,obj.gridLocations ,obj.accuracy),2);
            obj.maskBuilder(Dists>=1)=1;
            obj.gridLocations=obj.gridLocations(Dists>=1,:);
        end
    end

    % Override inherited methods.
    methods(Access=public)

        function VariablePadded=applyDirichletBoundaryCondition(obj,VariablePadded)
            % Recall the Values validated by ValidGridPointDistance
            ReducedVariable=VariablePadded(obj.maskPadded==1);
            % For each boundary point compute the pressure
            VariableBoundary=zeros(1,obj.offGrid.gridSize);
            VariableBoundary=VariableBoundary +  sum(obj.offGrid.BandLim(obj.gridLocations,obj.offGrid.gridLocations).' .* ReducedVariable,1);
            % Apply the inverse Matrix
            BoundaryChange =  obj.offGrid.InvBandLimMatrix * (obj.BoundaryValue-VariableBoundary.');
            %Compute the Grid re-weighting
            GridChange=zeros(length(obj.gridLocations(:,1)),1);
            GridChange=GridChange + sum( obj.offGrid.BandLimGrid(obj.gridLocations,obj.offGrid.gridLocations,obj.accuracy) .* BoundaryChange,1).';
            % For each grid Location compute the new pressure
            VariablePadded(obj.maskPadded==1)=ReducedVariable + real(GridChange) ;

        end

        function VariablePadded=applyNeumannBoundaryCondition(obj,VariablePadded)
            switch obj.kgrid.dimensions
                case 1
                    VariablePadded=applyDirichletBoundaryCondition(obj,VariablePadded);
                case 2
                    % Recall the Values validated by ValidGridPointDistance
                    Variable1=VariablePadded(:,:,1,1);
                    Variable2=VariablePadded(:,:,1,2);
                    ReducedVariable1=Variable1(obj.maskPadded==1);
                    ReducedVariable2=Variable2(obj.maskPadded==1);
                    % For each boundary point compute the pressure
                    VariableBoundary=zeros(obj.offGrid.gridSize,obj.kgrid.dimensions);
                    VariableBoundary(:,1)=VariableBoundary(:,1) + sum(obj.offGrid.BandLim(obj.gridLocations,obj.offGrid.gridLocations).' .* ReducedVariable1,1).';
                    VariableBoundary(:,2)=VariableBoundary(:,2) + sum(obj.offGrid.BandLim(obj.gridLocations,obj.offGrid.gridLocations).' .* ReducedVariable2,1).';
                    normalDeriv=sum( VariableBoundary.*(obj.offGrid.normalVector) ,2 );
                    CurrBoundaryValue1= (obj.BoundaryValue - normalDeriv).*((obj.offGrid.normalVector(:,1)));
                    CurrBoundaryValue2= (obj.BoundaryValue - normalDeriv).*((obj.offGrid.normalVector(:,2)));
                    
                    % Apply the inverse Matrix to how much each direction
                    % wants to change
                    BoundaryChange1 =  obj.offGrid.InvBandLimMatrix * CurrBoundaryValue1;
                    BoundaryChange2 =  obj.offGrid.InvBandLimMatrix * CurrBoundaryValue2;
                    
                    %Compute the Grid re-weighting
                    GridChange=zeros(length(obj.gridLocations(:,1)),2);
                    GridChange(:,1)=GridChange(:,1) + sum( obj.offGrid.BandLimGrid(obj.gridLocations,obj.offGrid.gridLocations,obj.accuracy) .* BoundaryChange1,1).';
                    GridChange(:,2)=GridChange(:,2) + sum( obj.offGrid.BandLimGrid(obj.gridLocations,obj.offGrid.gridLocations,obj.accuracy) .* BoundaryChange2,1).';
                    % For each grid Location compute the new pressure
                    Variable1(obj.maskPadded==1)=ReducedVariable1 + real(GridChange(:,1)) ;
                    Variable2(obj.maskPadded==1)=ReducedVariable2 + real(GridChange(:,2)) ;
                    VariablePadded(:,:,:,1)=Variable1;
                    VariablePadded(:,:,:,2)=Variable2;
                case 3

            end

            

        end

    end


end
