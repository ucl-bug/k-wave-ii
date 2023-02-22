%% kWaveSettings
% *Package:* kwave.toolbox
%
% Class used to define settings for k-Wave simulations.
%
%% Description
% Defines default settings used in the k-Wave simulation classes. To modify
% settings, first create a |kWaveSettings| object, then modify the
% properties. The object can then be passed as an input to the simulation
% classes.
%
%% Examples
%   settings = kwave.toolbox.kWaveSettings;
%   settings.plotSimulation = 'off';
%
%% Properties
% * |colorMap| - (numeric) Color map used for 2D plots. Default is the
%   k-Wave color map.
% * |plotFrequency| - (integer) The number of iterations which must pass 
%   before the simulation plot is updated. Default = 10.
% * |plotScale| - (numeric) [min, max] values used to control the scaling
%   for imagesc (visualisation). Default = [-1, 1].
% * |plotSimulation| - ('on', 'off') Option to progressively display the
%   running simulation. Default = 'on'.
% * |simulationDataType| - ('single', 'double') Data-type used for
%   simulation calculations.

% Copyright (C) 2022- University College London.
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

classdef kWaveSettings < handle
    properties
        colorMap(:,3) double = kwave.legacy.getColorMap
        plotFrequency(1,1) uint64 {mustBeInteger, mustBePositive, mustBeFinite} = 10
        plotScale(1,2) double = [-1, 1]
        plotSimulation(1,1) matlab.lang.OnOffSwitchState = 'on'
        simulationDataType(1,:) char {mustBeMember(simulationDataType, {'single', 'double'})} = 'single'
    end
end
