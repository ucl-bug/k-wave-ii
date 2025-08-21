%% AcousticBndryCond
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.BoundaryCondition
%
% The Acoustic Boundary Condition class is a subclass of the
% boundaryCondition class and adds properties and methods specifically for
% dictating to the solver which boundary condition should be used as well
% as how to feed them to the BoundaryCondition methods.
%
%% Syntax
%   BoundaryCondition = AcousticBndryCond(kgrid);
%
%% Description
%  The Acoustic Boundary Condition subclass of the BouncdaryCondition class 
%  contains the switches for which boundary conditions are to be applied, and 
%  passes the the BoundaryCondition class the variable in the correct format.
%  To run the acoustic boundary condition requires a mask defining the 
%  boundary. This can be either by writing the
%  mask manually for a on-grid boundary. Or, by assigning an off-grid object
%  and using the mask builder.  The methods contained adapt based on the
%  presence of the BLI terms when an offgrid is applied, with these set to
%  1's when on grid methods are used.
%% Examples
%    kgrid = kwave.toolbox.Grid([128, 128], 1e-3);
%    BoundaryCondition = kwave.toolbox.AcousticBndryCond(kgrid);
%    BoundaryCondition.mask=zeros(128,128);
%    BoundaryCondition.mask(12,:)=1;
%    BoundaryCondition.bndryVal=0;
%    BoundaryCondition.pressureBndry='on';
%    solver=AcousticSolver(kgrid,medium,source,sensor,settings)
%    solver.applyBoundaryCondition(BoundaryConditon);
%
%    BoundaryCondition2=kwave.toolbox.AcousticBndryCond(kgrid);
%    circ.radius=5e-2;
%    circ.centre=[0,0];
%    circ.points=315;
%    offGrid=OffGrid(kgrid,'circle',circ);
%    Accuracy=1e-4;
%    BoundaryCondition2.setOffGrid(kgrid,offGrid,Accuracy);
%    BoundaryCondition2.mask=BoundaryCondition2.maskBuilder;
%    BoundaryCondition2.bndryVal=0;
%    BoundaryCondition2.pressureBndry='on';
%    solver2=AcousticSolver(kgrid,medium,source,sensor,settings)
%    solver2.applyBoundaryCondition(BoundaryConditon2);
%
%% Properties
% * |mask|
% * |OffGridApplied| -  'on' 'off' witch that declares if offgrid methods
% are being used. automatically turned on when calling setOffGrid(OffGrid,accuracy)
% * |OffGrid| -  the Offgrid object used to call the oggrid methods.
% * |normal| - the outward unit normal to the boundary for use in the
% neumann boundary condition, NOT YET IMPLEMENTED
% * |bndryVal| - scalar or vecot of values of the time invariant value at
% the boundary of the domain. Defaults to 0.
% * |pressureBndry| - 'on' 'off' switch that declares if a pressure
% boundary condition is being applied. Defaults to 'off'
% * |velocityBndry| - 'on' 'off' switch that declares if a velocity through
% a neumann boundary condition is being applied. Defaults to 'off'.
%% See Also
% * |BoundaryCondition|
% * |OffGrid|
%
% The velocity boundary condition is yet to be implemented.

classdef AcousticBndryCond < kwave.toolbox.BoundaryCondition

    properties 
        pressureBndry char {mustBeMember( pressureBndry, {'on','off'})} = 'off';
        velocityBndry char {mustBeMember( velocityBndry, {'on','off'})} = 'off';
    end

    methods(Access=public)
        function pressurePadded =applyPressureBndry(obj,Solver)
                pressurePadded=obj.ApplyBoundaryCondition(Solver.pressurePadded,'dirichlet',1,'none');
        end

    %     function velocityPadded=applyVelocityBndry(obj,Solver,stag)
    %         GridVelocityPadded=zeros(size(Solver.velocityPadded));
    %         if strcmp(stag,'on')
    %             for dim=1:Solver.kgrid.dimensions
    %                 Unstagger=Solver.stagger(Solver.velocityPadded(:,:,:,dim),Staggering='backward');
    %                 GridVelocityPadded(:,:,:,dim)=Unstagger(:,:,:,dim);
    %             end
    %             velocityUnstg=obj.ApplyBoundaryCondition(GridVelocityPadded,Solver.kgrid.dimensions,'neumann','none');
    %             velocityPadded=zeros(size(Solver.velocityPadded));
    %             for dim=1:Solver.kgrid.dimensions
    %                 Unstagger=Solver.stagger(velocityUnstg,Staggering='backward');
    %                 velocityPadded(:,:,:,dim)=Unstagger(:,:,:,dim);
    %             end
    %         else
    %             velocityPadded=obj.ApplyBoundaryCondition(Solver.velocityPadded,3,'neumann','none');
    %         end  
    %     end
  
   end



end