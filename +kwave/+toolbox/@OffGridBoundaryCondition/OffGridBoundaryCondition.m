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

classdef OffGridBoundaryCondition < kwave.toolbox.BoundaryCondition

    % PDE variables.
    properties(SetAccess=private, Dependent=true)
        mask
    end

    % PDE variables on padded domain, and PML variables.
    properties(SetAccess=private, Hidden=true)
        maskPadded
    end
    
    properties(SetAccess=public,Hidden=false)
        
    end

    properties(SetAccess=private, Hidden=true)
        
    end

    % Constructor.
    methods
        function obj = OffGridBoundaryCondition(kGrid, offGrid)
            arguments
                kGrid
                offGrid
            end
            obj.kGrid
            obj.offGrid

            obj.maskPadded=

        end
    end

    methods
        function mask = get.mask(obj)
            mask = obj.kgrid.returnWithoutGridPadding(obj.maskPadded);
        end
    end
    
    % Override inherited methods and add specific methods.
    methods(Access=protected)
         function VariablePadded=applyBoundaryCondition(obj,VariablePadded)

         end        
    end

    methods(Access=public)
    end
end