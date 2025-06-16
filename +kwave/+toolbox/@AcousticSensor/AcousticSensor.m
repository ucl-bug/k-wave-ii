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

classdef AcousticSensor < kwave.toolbox.Sensor

    properties 
        pressureSensor char {mustBeMember( pressureSensor, {'on','off'})} = 'on'
        velocitySensor char {mustBeMember( velocitySensor, {'on','off','ongrid'})} = 'off'
        densitySensor char {mustBeMember( densitySensor, {'on','off'})} = 'off'

        pressure=[];
        velocity=[];
        density=[];
        times=[];
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
                 if (strcmp(obj.velocitySensor,'on') || strcmp(obj.velocitySensor,'onGrid')) && isempty(obj.velocity)
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
                if strcmp(obj.velocitySensor,'on') || strcmp(obj.velocitySensor,'onGrid')
                     if isempty(obj.velocity)
                        id=1;
                        obj.velocity=[zeros(obj.totalSensorPoints,floor(Nt/obj.timeSteps)+1,obj.kgrid.dimensions)];
                     else
                         id=2;
                         obj.velocity=[obj.velocity,zeros(obj.totalSensorPoints,floor(Nt/obj.timeSteps),obj.kgrid.dimensions)];
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
            mask=Solver.kgrid.returnWithoutGridPadding(obj.maskPadded);
            if strcmp(obj.pressureSensor,'on')
                obj.pressure(:,n)=Solver.pressure(mask==1);
            end
            if strcmp(obj.densitySensor,'on')
                for dim=1:obj.kgrid.dimensions
                Density=Solver.densitySplit(:,:,:,dim);
                obj.density(:,n)=obj.density(:,n)+Density(mask==1);
                end
            end
            if strcmp(obj.velocitySensor,'on')
                for dim=1:Solver.kgrid.dimensions
                    Velocity=Solver.velocity(:,:,:,dim);
                    obj.velocity(:,n,dim)=Velocity(mask==1,dim);
                end
            elseif strcmp(obj.velocitySensor,'onGrid')
                for dim=1:Solver.kgrid.dimensions
                    GridVelocityPadded=stagger(Solver.velocityPadded(:,:,:,dim),Staggering='backward');
                    GridVelocity=Solver.kgrid.returnWithoutGridPadding(GridVelocityPadded(:,:,:,dim));
                    obj.velocity(:,n,dim)=GridVelocity(mask==1);
                end
            end
            obj.times(n)=Solver.timePoint;
        end
    end



end