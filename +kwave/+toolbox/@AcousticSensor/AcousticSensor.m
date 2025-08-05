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
        densitySensor char {mustBeMember( densitySensor, {'on','off'})} = 'off'

        pressure single
        velocity single;
        density single;
        times single;
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
                    obj.pressure=zeros(obj.totalSensorPoints,1);
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