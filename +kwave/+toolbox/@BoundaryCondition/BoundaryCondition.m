%% BoundaryCondition
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

classdef BoundaryCondition < kwave.toolbox.GridInput

    properties(Constant, Hidden=true)
        requiredProperties = {'mask'};
        gridFields = kwave.toolbox.GridField.createGridFieldsMap([
            kwave.toolbox.GridField('mask', Attributes={'real', 'finite'})
        ]);
    end

    properties 
        BoundaryValue single {mustBeReal, mustBeFinite} = 0; 
        normalVector=[];
        % mask kwave.toolbox.GridField = [];
        % For now this is just a scalar applied across the whole boundary, update to allow spatial variation, update to allow temporal variation.
    end

    properties(Hidden)
        staggering='forward'
    end

    methods(Access=public)
        function VariablePadded=applyDirichletBoundaryCondition(obj,VariablePadded)
            ChangeValue=obj.maskPadded.*obj.BoundaryValue - VariablePadded;
            VariablePadded=VariablePadded + (obj.maskPadded~=0).*ChangeValue;
            % returns the same variable adjusted according to the
            % BoundaryValue and the Mask. Something needs to check if the
            % mask is actually grid Size.
        end

        function VariablePadded=applyNeumannBoundaryCondition(obj,VariablePadded)
            switch obj.kgrid.dimensions
                case 1
                    VariablePadded=applyDirichletBoundaryCondition(obj,VariablePadded);
                case 2
                    %This does not change variable in the tangent direction           
                        Value = obj.normalVector(:,:,:,1).*VariablePadded(:,:,:,1) + obj.normalVector(:,:,:,2).*VariablePadded(:,:,:,2);
                        ChangeValue=obj.maskPadded.*obj.BoundaryValue - Value;
                        Val1=(obj.maskPadded~=0).*ChangeValue.*obj.normalVector(:,:,:,1);
                        Val2=(obj.maskPadded~=0).*ChangeValue.*obj.normalVector(:,:,:,2);
                        VariablePadded(:,:,:,1)=VariablePadded(:,:,:,1) + Val1(:,:,:);
                        VariablePadded(:,:,:,2)=VariablePadded(:,:,:,2) + Val2(:,:,:);
                case 3
                    % Needs to be implemented
                    Value = obj.normalVector(:,:,:,1).*VariablePadded(:,:,:,1) + obj.normalVector(:,:,:,2).*VariablePadded(:,:,:,2)+ obj.normalVector(:,:,:,3).*VariablePadded(:,:,:,3);
                    ChangeValue=obj.maskPadded.*obj.BoundaryValue - Value;
                    Val1=(obj.maskPadded~=0).*ChangeValue.*obj.normalVector(:,:,:,1);
                    Val2=(obj.maskPadded~=0).*ChangeValue.*obj.normalVector(:,:,:,2);
                    Val3=(obj.maskPadded~=0).*ChangeValue.*obj.normalVector(:,:,:,3);
                    VariablePadded(:,:,:,1)=VariablePadded(:,:,:,1) + Val1(:,:,:);
                    VariablePadded(:,:,:,2)=VariablePadded(:,:,:,2) + Val2(:,:,:);
                    VariablePadded(:,:,:,2)=VariablePadded(:,:,:,2) + Val3(:,:,:);

            end
        end
    end



end


