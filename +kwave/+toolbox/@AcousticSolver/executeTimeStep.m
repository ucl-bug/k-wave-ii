%% executeTimeStep
% *Class:* kwave.toolbox.AcousticSolver
% *Package:* kwave.toolbox
%
% Iteratively update solution for given number of time steps.
%
%% Syntax
%   executeTimeStep(obj, Nt, dt)
%
%% Description
% Iteratively updates the solution for the acoustic field for the given
% number of time steps and time step size.
%
%% Input Arguments
% * |Nt| - (integer) Number of time steps.
% * |dt| - (numeric) Size of each time step.

% Copyright (C) 2024- The k-Wave Authors.
%
% This file is part of k-Wave-II (http://www.k-wave.org). k-Wave-II is free
% software: you can redistribute it and/or modify it under the terms of the
% GNU Lesser General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any
% later version.
%
% k-Wave-II is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
% License for more details.
%
% You should have received a copy of the GNU Lesser General Public License
% along with k-Wave-II. If not, see <http://www.gnu.org/licenses/>.

function executeTimeStep(obj, Nt, dt)

arguments
    obj
    Nt(1,1) {mustBeInteger, mustBeNonnegative, mustBeFinite}
    dt(1,1) {mustBeNumeric, mustBePositive, mustBeFinite}
end

% Sets absorption Coefficients only when absorption is requested.
if ~strcmp(obj.absorptionType,'off')
    setAbsorptionCoefficients(obj)
end

% Update time variables to account for changes in time step size.
currentTimeStep = dt;
if (~isempty(obj.prevTimeStep))
    dt = (currentTimeStep + obj.prevTimeStep)/2;
end

% Set k-space correction (use currentTimeStep step).
obj.setkSpaceCorrection(currentTimeStep);

% Set PML variables (use average time step dt).
obj.pml.setupQuarticPML(dt, obj.medium.soundSpeedReference);

% Anonymous functions to simplify code within time loop.
pml = @(x) obj.pml.applyPML(x);
pmlSG = @(x) obj.pml.applyPML(x, Staggered=true);
gradient = @(x) obj.gradient(x, Staggering='forward');
divergence = @(x) obj.divergenceSplit(x, Staggering='backward');

if length(obj.medium.densityPadded)~= 1
    densityPaddedStg=obj.stagger(obj.medium.densityPadded,Stagger='forward', Type='linInterpolate');
else
    densityPaddedStg=obj.medium.densityPadded;
end
densityMultiplier=obj.medium.densityPadded;

if (obj.settings.plotSimulation)
    fig = figure;
end

if (obj.timeStepsTaken == 0)
    % Adds a time step if initial conditions need applying.
    Nt=Nt+1;
end

if Nt~=0
    %If no time steps are taken for a system that has been run then the
    %original solution is passed back out.
    for tIndex = 1:Nt

        if (tIndex == 1) && (obj.timeStepsTaken == 0)
            if isempty(obj.source.initialVelocity)
                % Sets initial conditions with velocity(t=0)=0 through
                % assuming V(-t)=v(t).
                obj.pressurePadded = obj.pressurePadded + obj.source.initialPressurePadded;
                obj.densitySplitPadded = obj.densitySplitPadded + obj.source.initialPressurePadded ./ (obj.dimensions * obj.medium.soundSpeedPadded.^2);
                obj.velocityPadded = (dt ./ densityPaddedStg) .* gradient(obj.pressurePadded) / 2;
            else
                % If Velocity Initial condition is given the initial
                % conditions account for staggering and the offset time
                % stepping
                obj.pressurePadded = obj.pressurePadded + obj.source.initialPressurePadded;
                obj.densitySplitPadded = obj.densitySplitPadded + obj.source.initialPressurePadded ./ (obj.dimensions * obj.medium.soundSpeedPadded.^2);
                initialVelocityDimensional=zeros([obj.kgridPadded.gridSize,obj.kgrid.dimensions])+obj.source.initialVelocityPadded;
                for dim=1:obj.kgrid.dimensions
                    initialVelcoityStaggered=obj.stagger(initialVelocityDimensional(:,:,:,dim), Type='fourier');
                    obj.velocityPadded(:,:,:,dim) = obj.velocityPadded(:,:,:,dim) + initialVelcoityStaggered(:,:,:,dim);
                end
                clear('initialVelcoityStaggered','initialVelocityDimensional')
                obj.prevTimeStep=0;
                dt = (currentTimeStep)/2;
                obj.pml.setupQuarticPML(dt, obj.medium.soundSpeedReference);
                obj.setkSpaceCorrection(currentTimeStep);
            end
        else
            % Conservation of Momentum,
            if ((tIndex==2) && (obj.timeStepsTaken == 0)) || ((tIndex==1) && (obj.timeStepsTaken ~= 0))
                % Variable time stepping term is 0 for constant time stepping
            obj.velocityPadded = pmlSG(pmlSG(obj.velocityPadded) - (dt ./ densityPaddedStg) .* g\radient(obj.pressurePadded) + dt .* obj.kappaSplitCorrection( pmlSG(obj.velocityPadded)) );
                % Update time step sizes and k-space corrections
                dt = currentTimeStep;
                obj.prevTimeStep = currentTimeStep;
                obj.setkSpaceCorrection(currentTimeStep);
                obj.pml.setupQuarticPML(currentTimeStep, obj.medium.soundSpeedReference);
            else
                % Variable time stepping term is 0 for constant time stepping
            obj.velocityPadded = pmlSG(pmlSG(obj.velocityPadded) - (dt ./ densityPaddedStg) .* gradient(obj.pressurePadded));
            end

            % Mass conservation equation.
            if ~strcmp(obj.nonLinearity,'off')
                densityMultiplier = 2* sum(obj.densitySplitPadded,4) + obj.medium.densityPadded;
            end
            obj.densitySplitPadded = pml(pml(obj.densitySplitPadded) - dt .* densityMultiplier .* divergence(obj.velocityPadded));
            % Pressure density relation.
            obj.pressurePadded = obj.medium.soundSpeedPadded.^2 .* ( sum(obj.densitySplitPadded, 4));
            % If absorptionPower declaired then add absorption terms
            if ~strcmp(obj.absorptionType,'off')
                obj.pressurePadded =  obj.pressurePadded  +  obj.medium.soundSpeedPadded.^2 .* ( ...
                    obj.absorbTauPadded .* fracLaplacian(obj, obj.medium.densityPadded .* sum(divergence(obj.velocityPadded),4), obj.medium.absorptionPower/2 -1 ) + ...
                    obj.absorbEtaPadded .* fracLaplacian(obj, sum(obj.densitySplitPadded,4), obj.medium.absorptionPower/2 -0.5 ) ) ;
            end
            if ~strcmp(obj.nonLinearity,'off')
                obj.pressurePadded =  obj.pressurePadded  +  obj.medium.soundSpeedPadded.^2 .* ( ...
                    obj.medium.BonAPadded.*  ( sum(obj.densitySplitPadded, 4)).^2 ./ (2 * obj.medium.densityPadded)  );
            end
        end

        % Plot.
        if obj.settings.plotSimulation && (rem(tIndex, obj.settings.plotFrequency) == 0 || tIndex == 1 || tIndex == Nt)
            figure(fig);
            obj.plotField(obj.pressure);
        end

    end
end

end
