%% AcousticSensor
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.Sensor
%
%% Syntax
% AcousticSensor=AcousticSensor(kgrid)
%% Description
% Informs the sensor superclass which variables are recorded and how.
% performs the variable manipulations before they are passed to the sensor
% for reading and being stored. Methods in the sensor class vary based on
% OffGrid properties. This has no impact on the AcousticSensor.
%% Examples
% Define the grid and sensor objects, and assign the mask, both by defining
% a mask directly, and by using an offGrid object.
%
%    kgrid = kwave.toolbox.Grid([128, 128], 1e-3);
%    sensor = kwave.toolbox.Sensor(kgrid);
%    sensor.mask=zeros(128,128);
%    sensor.mask(12:254,12:24)=1;
%    sensor.pressureSensor='off';
%    sensor.densitySensor='on';
%    sensor.velocitySensor='on';
%
%    sensor2=kwave.toolbox.Sensor(kgrid);
%    circ.radius=5e-2;
%    circ.centre=[0,0];
%    circ.points=315;
%    offGrid=OffGrid(kgrid,'circle',circ);
%    sensor2.setOffGrid(kgrid,offGrid,1e-4);
%    sensor2.mask=sensor2.maskBuilder;
%    sensor2.velocitySensor='ongrid'
%
%% Properties
% * |sensor Properties|
% * |pressureSensor| - 'on'/'off' switch for if pressure data should be
% recorded
% * |densitySensor| - 'on'/'off' switch for if density data should be
% recorded 
% * |velocitySensor| - 'on'/'off' switch for if velocity data should be
% recorded. Can additionally take the value 'ongrid' to use fourier
% interpolation to record the velocity on the grid points, not the offset
% computation locations.
% * |pressure| - (single) array of the pressure readings at the sensor
% locations, in sensor number and time point.
% * |density| - (single) array of the density readings at the sensor
% locations, in sensor number and time points
% * |velocity| - (single) array of the velocity readings at the sensor
% locations, in sensor number, dimensional direction and time point
% * |times| - (single) vector of the recorded time points.
%% See Also
% * Sensor
% * AcousticSolver

classdef AcousticSensor < kwave.toolbox.Sensor

    properties 
        pressureSensor char {mustBeMember( pressureSensor, {'on','off'})} = 'on'
        velocitySensor char {mustBeMember( velocitySensor, {'on','off','ongrid'})} = 'off'
        densitySensor char {mustBeMember( densitySensor, {'on','off'})} = 'off'

        pressure single = [];
        velocity single = [];
        density single = [];
        times single = [];
    end

    methods(Access=public)
        function obj=initialiseSensorData(obj,Nt)
            id=0;
            if Nt==0
                 if strcmp(obj.pressureSensor,'on') && isempty(obj.pressure)
                    id=1;
                    obj.pressure=zeros(obj.totalSensorPoints,1);
                 end
                 if strcmp(obj.densitySensor,'on') && isempty(obj.density)
                    id=1;
                    obj.density=zeros(obj.totalSensorPoints,1);
                 end
                 if (strcmp(obj.velocitySensor,'on') || strcmp(obj.velocitySensor,'ongrid')) && isempty(obj.velocity)
                    id=1;
                    obj.velocity=zeros(obj.totalSensorPoints,1,obj.kgrid.dimensions);
                 end
                 if id==1
                    obj.times=0;
                 end
            else
                 if strcmp(obj.pressureSensor,'on')
                     if isempty(obj.pressure)
                         id=1;
                         obj.pressure=[zeros(obj.totalSensorPoints,floor(Nt/obj.timeSteps)+1)];
                     else
                         id=2;
                         obj.pressure=[obj.pressure,zeros(obj.totalSensorPoints,floor(Nt/obj.timeSteps))];
                     end
                end
                if strcmp(obj.densitySensor,'on')
                     if isempty(obj.density)
                         id=1;
                         obj.density=[zeros(obj.totalSensorPoints,floor(Nt/obj.timeSteps)+1)];
                     else
                         id=2;
                         obj.density=[obj.density,zeros(obj.totalSensorPoints,floor(Nt/obj.timeSteps))];
                     end
                end
                if strcmp(obj.velocitySensor,'on') || strcmp(obj.velocitySensor,'ongrid')
                     if isempty(obj.velocity)
                        id=1;
                        obj.velocity=[zeros(obj.totalSensorPoints,obj.kgrid.dimensions,floor(Nt/obj.timeSteps)+1)];
                     else
                         id=2;
                         obj.velocity=cat(3,obj.velocity,zeros(obj.totalSensorPoints,obj.kgrid.dimensions,floor(Nt/obj.timeSteps)));
                     end
                end
                if id==1
                    obj.times=zeros(1,floor(Nt/obj.timeSteps)+1);
                elseif id==2
                    obj.times=[obj.times,zeros(1,floor(Nt/obj.timeSteps))];
                end

            end
        end

        function obj =recordSensorData(obj,Solver,n)

            if strcmp(obj.velocitySensor,'ongrid') && strcmp(Solver.settings.spatialStaggering,'on')
                obj.velocitySensor='on';
                disp("Velocity computed on grid, sensor automatically record on-grid");
            end

            if strcmp(obj.pressureSensor,'on')
                obj.pressure(:,n)=obj.ProcessSensorData(Solver.pressure,1,'none');
            end
            if strcmp(obj.densitySensor,'on')
                obj.density(:,n)=obj.ProcessSensorData(Solver.densitySplit,obj.kgrid.dimensions,'sum');
            end
            if strcmp(obj.velocitySensor,'on')
                obj.velocity(:,:,n)=obj.ProcessSensorData(Solver.velocity,obj.kgrid.dimensions,'none');
            elseif strcmp(obj.velocitySensor,'ongrid')
                GridVelocityPadded=zeros(size(Solver.velocityPadded));
                for dim=1:Solver.kgrid.dimensions
                    Unstagger=Solver.stagger(Solver.velocityPadded(:,:,:,dim),Staggering='backward');
                    GridVelocityPadded(:,:,:,dim)=Unstagger(:,:,:,dim);
                end
                obj.velocity(:,:,n)=obj.ProcessSensorData(Solver.kgrid.returnWithoutGridPadding(GridVelocityPadded),obj.kgrid.dimensions,'none');
            end
            obj.times(n)=Solver.timePoint;
        end

    end



end