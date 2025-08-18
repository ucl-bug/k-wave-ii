%% AcousticSensor
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.BoundaryCondition
%
%% Syntax
%% Description
%% Examples
%
%% Properties
%% See Also

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