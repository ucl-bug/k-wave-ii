%% AcousticSensor
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.Sensor
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

classdef AcousticSensor < kwave.toolbox.Sensor

    properties 
        pressureSensor char {mustBeMember( pressureSensor, {'on','off'})} = 'on'
        velocitySensor char {mustBeMember( velocitySensor, {'on','off','ongrid'})} = 'off'
        densitySensor  char {mustBeMember( densitySensor,  {'on','off'})} = 'off'

        pressure = [];
        velocity = [];
        density  = [];
        times    = [];
    end

    methods(Access=public)


        function obj=initialiseSensorData(obj,Nt)
            id=0;
            if Nt==0
                 if strcmp(obj.pressureSensor,'on') && isempty(obj.pressure)
                    id=1;
                    obj.pressure = single(zeros(obj.totalSensorPoints,1));
                 end
                 if strcmp(obj.densitySensor,'on') && isempty(obj.density)
                    id=1;
                    obj.density = single(zeros(obj.totalSensorPoints,1));
                 end
                 if (strcmp(obj.velocitySensor,'on') || strcmp(obj.velocitySensor,'ongrid')) && isempty(obj.velocity)
                    id=1;
                    obj.velocity = single(zeros(obj.totalSensorPoints,obj.kgrid.dimensions,1));
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
    
        % Assign the acoustic variables to the sensors
        function obj = recordSensorData(obj,solver,n)

            import kwave.toolbox.FourierCollocation

            if strcmp(obj.pressureSensor,'on')
                obj.pressure(:,n) = obj.ProcessSensorData(solver.pressure,1,'none');
            end
            if strcmp(obj.densitySensor,'on')
                obj.density(:,n) = obj.ProcessSensorData(solver.densitySplit,obj.kgrid.dimensions,'sum');
            end
            if strcmp(obj.velocitySensor,'on')
                obj.velocity(:,:,n) = obj.ProcessSensorData(solver.velocity,obj.kgrid.dimensions,'none');
            elseif strcmp(obj.velocitySensor,'ongrid')
                GridVelocityPadded = zeros(size(solver.velocityPadded));
                for dim=1:solver.kgrid.dimensions
                    GridVelocityPadded(:,:,:,dim) = stagger(solver,solver.velocityPadded(:,:,:,dim),Staggering='backward');
                end
                obj.velocity(:,:,n) = obj.ProcessSensorData(solver.kgrid.returnWithoutGridPadding(GridVelocityPadded),obj.kgrid.dimensions,'none');
            end
            obj.times(n) = solver.timePoint;
        end

    end



end