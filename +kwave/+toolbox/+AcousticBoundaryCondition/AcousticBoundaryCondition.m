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

classdef AcousticBoundaryCondition < kwave.toolbox.BoundaryCondition

    properties 
        pressureBndry char {mustBeMember( pressureBndry, {'on','off'})} = 'off';
        velocityBndry char {mustBeMember( velocityBndry, {'on','off'})} = 'off';
    end

    methods(Access=public)
        function pressurePadded =applyPressureBndry(obj,Solver)
                pressurePadded=obj.ApplyBoundaryCondition(Solver.pressurePadded,1,'dirichlet','none');
        end

        function velocityPadded=applyVelocityBndry(obj,Solver,stag)
            GridVelocityPadded=zeros(size(Solver.velocityPadded));
            if strcmp(stag,'on')
                for dim=1:Solver.kgrid.dimensions
                    Unstagger=Solver.stagger(Solver.velocityPadded(:,:,:,dim),Staggering='backward');
                    GridVelocityPadded(:,:,:,dim)=Unstagger(:,:,:,dim);
                end
                velocityUnstg=obj.ApplyBoundaryCondition(GridVelocityPadded,Solver.kgrid.dimensions,'neumann','none');
                velocityPadded=zeros(size(Solver.velocityPadded));
                for dim=1:Solver.kgrid.dimensions
                    Unstagger=Solver.stagger(velocityUnstg,Staggering='backward');
                    velocityPadded(:,:,:,dim)=Unstagger(:,:,:,dim);
                end
            else
                velocityPadded=obj.ApplyBoundaryCondition(Solver.velocityPadded,3,'neumann','none');
            end  
        end

    end



end