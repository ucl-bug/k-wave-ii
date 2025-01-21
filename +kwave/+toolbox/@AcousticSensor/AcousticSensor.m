%% AcousticSensor
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.GridInput
%
%% Syntax
%
%% Description
%
%% Examples
%
%% Properties
%
%% See Also
%
%% Writing Notes
% Needs to input a mask to construct and a 'mask sized' vector of values
% Needs an overwritable method that applies the boundary condition
% according to the mask,
% takes a grid variable, returns the same grid variable but
% adjustedaccording to the boundary condition
% OffGridBoundaryCondition updates ontop of this to use the band limited
% versions.

classdef AcousticSensor < Sensor

    properties 
        pressureSensor char {mustBeMember( pressureSensor, {'on','off'})} = 'off'
        velocitySensor char {mustBeMember( velocitySensor, {'on','off','ongrid'})} = 'off'
        densitySensor char {mustBeMember( densitySensor, {'on','off'})} = 'off'
    end

    methods(Access=public)
        function obj =recordSensorData(obj)
            obj;
        end
    end



end