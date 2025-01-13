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
        % For now this is just a scalar applied across the whole boundary, update to allow spatial variation, update to allow temporal variation.
    end

    methods
        function VariablePadded=applyBoundaryCondition(obj,VariablePadded)

            ChangeValue=obj.maskPadded.*obj.BoundaryValue - VariablePadded;

            VariablePadded=VariablePadded + (obj.maskPadded~=0).*ChangeValue;
            % returns the same variable adjusted according to the
            % BoundaryValue and the Mask. Something needs to check if the
            % mask is actually grid Size.
        end

    end

end


