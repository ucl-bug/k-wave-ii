%% Sensor
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.GridInput
%
% Superclass of all kwave.toolbox sensor classes. 
%
%% Description
% Abstract class used to define sensors. All sensor classes should be
% derived from this class. 
%
%% Properties
% * |mask|           - Binary mask the size of the grid with 1s indicated
%                      sensor positions.
%
%% See Also
% * |kwave.toolbox.AcousticSensor|
% * |kwave.toolbox.Grid|
% * |kwave.toolbox.GridInput|

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

classdef Sensor < kwave.toolbox.GridInput

    properties(Constant, Hidden=true)

        requiredProperties = {'mask'};

        gridFields = kwave.toolbox.GridField.createGridFieldsMap([
            kwave.toolbox.GridField('mask', Classes={'logical','numeric'},... 
            Attributes={'binary'})]);
    end

    properties
        timeSteps(1,1) {mustBeInteger, mustBeFinite, mustBePositive} = 1;
    end

    properties(Hidden)
        sensorIndex(1,1) single {mustBeInteger, mustBeFinite, mustBeNonnegative} = 0;
        totalSensorPoints =0;
    end

    methods
        function totalSensorPoints=get.totalSensorPoints(obj)
            obj.totalSensorPoints= sum(obj.kgrid.returnWithoutGridPadding(obj.maskPadded),'all');
            totalSensorPoints=obj.totalSensorPoints;
        end
        % function obj=multiDimMask(obj)
        %     obj.multiDimMask=zeros(obj.kgrid.gridSize,obj.kgrid.dimensions);
        %     for dim=1:obj.kgrid.dimensions
        %         obj.multiDimMask(:,:,:,dim)=obj.kgrid.returnWithoutGridPadding(obj.maskPadded);
        %     end
        % end
        function SensorOutput = ProcessSensorData(obj,Variable,dim,string)
            mask = obj.kgrid.returnWithoutGridPadding(obj.maskPadded);
            if ~strcmp(string,'sum')
                SensorOutput = single(zeros(obj.totalSensorPoints,dim));
                for dimension = 1:dim
                    Var = Variable(:,:,:,dimension);
                    SensorOutput(:,dimension) = Var(mask==1);
                end
            else
                SensorOutput = single(zeros(obj.totalSensorPoints,1));
                for dimension = 1:dim
                    Var = Variable(:,:,:,dimension);
                    SensorOutput = SensorOutput + Var(mask==1);
                end
            end
        end
    end
end