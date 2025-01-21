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

%
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

if (obj.settings.plotSimulation)
    fig = figure;
end

if (obj.timeStepsTaken == 0)
    % If no time steps have been taken, include an extra time step to
    % initialise the problem
    Nt=Nt+1;
end

if Nt~=0
    % So that no time steps are taken if the problem has been previously
    % run, but Nt=0 has been requested. The result is the same pressure,
    % velocity, density etc are returned.
    for tIndex = 1:Nt

        if (tIndex == 1)
            if (obj.timeStepsTaken == 0)

                if isempty(obj.source.initialVelocity)
                    % Set initial conditions for a photoacoustic initial value problem.
                    % We do this here, rather than in setInitialConditions, as setting
                    % the initial particle velocity requires the time step. The
                    % calculated density term is automatically copied to all components
                    % of densitySplit via implicit expansion.
                    obj.pressurePadded = obj.pressurePadded + obj.source.initialPressurePadded;
                    obj.densitySplitPadded = obj.densitySplitPadded + obj.source.initialPressurePadded ./ (obj.dimensions * obj.medium.soundSpeedPadded.^2);
                    obj.velocityPadded = (dt ./ densityPaddedStg) .* gradient(obj.pressurePadded) / 2;

                else
                    % If Velocity Initial condition is given then
                    % obj.velocityPadded = obj.source.initialVelocityPadded;
                    % obj.pressurePadded = obj.source.initialPressurePadded;
                    % obj.densitySplitPadded = obj.densitySplitPadded + obj.source.initialPressurePadded ./ (obj.dimensions * obj.medium.soundSpeedPadded.^2);
                    % But the first new time step must be computed differently.
                    % So we will want to store
                    % obj.prevTimeStep=0
                    % Then the first time step for velocity MUST be different
                    obj.pressurePadded = obj.pressurePadded + obj.source.initialPressurePadded;
                    obj.densitySplitPadded = obj.densitySplitPadded + obj.source.initialPressurePadded ./ (obj.dimensions * obj.medium.soundSpeedPadded.^2);
                    obj.velocityPadded = obj.velocityPadded + obj.source.initialVelocityPadded;

                    obj.prevTimeStep=0;
                    dt = (currentTimeStep)/2;
                    obj.pml.setupQuarticPML(dt, obj.medium.soundSpeedReference);
                    obj.setkSpaceCorrection(currentTimeStep);
                end
            else
                % Momentum conservation equation.
                % kspace corrected with split time step with current time
                % considerations. Need to add method that transforms and
                % untransforms F^-1(F(U(t))kappa_2(k))
                obj.velocityPadded = pmlSG(pmlSG(obj.velocityPadded) - (dt ./ densityPaddedStg) .* gradient(obj.pressurePadded) + dt .* obj.kappaSplitCorrection( pmlSG(obj.velocityPadded)) );

                dt = currentTimeStep;
                obj.prevTimeStep = currentTimeStep;
                obj.setkSpaceCorrection(currentTimeStep);
                obj.pml.setupQuarticPML(currentTimeStep, obj.medium.soundSpeedReference);

                % Mass conservation equation.
                obj.densitySplitPadded = pml(pml(obj.densitySplitPadded) - dt .* obj.medium.densityPadded .* divergence(obj.velocityPadded));

                % Pressure density relation.
                obj.pressurePadded = obj.medium.soundSpeedPadded.^2 .* ( sum(obj.densitySplitPadded, 4));

                % If absorptionPower declaired then add absorption terms
                if ~strcmp(obj.absorptionType,'off')
                    obj.pressurePadded =  obj.pressurePadded  +  obj.medium.soundSpeedPadded.^2 .* ( ...
                        obj.absorbTauPadded .* fracLaplacian(obj, obj.medium.densityPadded .* sum(divergence(obj.velocityPadded),4), obj.medium.absorptionPower/2 -1 ) + ...
                        obj.absorbEtaPadded .* fracLaplacian(obj, sum(obj.densitySplitPadded,4), obj.medium.absorptionPower/2 -0.5 ) ) ;
                end
            end
        elseif (tIndex==2) && (obj.timeStepsTaken == 0) && ~isempty(obj.source.initialVelocity)
            % An elseif tIndex==2 && no time steps had been taken before the initial conditions && we had an initial Velocity
            % Undates the kspace correction for the prevtime step being 0.aswell as the PML
            % Computes first time step as above. Check Formula still work with dt1=0.
            % Resets the current time step and prev time step and the correction aswell as PML
            % does rest of time step as usual. Carries on as usual.

            % Momentum conservation equation.
            % kspace corrected with split time step with current time
            % considerations. This is a special case with dt1=0, which
            % reduces kappa1 to sinc(ckdt/2), and kappa2 to (2cos(ckdt/2)-1)/dt
            obj.velocityPadded = pmlSG(pmlSG(obj.velocityPadded) - (dt ./ densityPaddedStg) .* gradient(obj.pressurePadded) + dt .* obj.kappaSplitCorrection( pmlSG(obj.velocityPadded)) );

            dt = currentTimeStep;
            obj.prevTimeStep = currentTimeStep;
            obj.setkSpaceCorrection(currentTimeStep);
            obj.pml.setupQuarticPML(currentTimeStep, obj.medium.soundSpeedReference);

            % Mass conservation equation.
            obj.densitySplitPadded = pml(pml(obj.densitySplitPadded) - dt .* obj.medium.densityPadded .* divergence(obj.velocityPadded));

            % Pressure density relation.
            obj.pressurePadded = obj.medium.soundSpeedPadded.^2 .* ( sum(obj.densitySplitPadded, 4));

            % If absorptionPower declaired then add absorption terms
            if ~strcmp(obj.absorptionType,'off')
                obj.pressurePadded =  obj.pressurePadded  +  obj.medium.soundSpeedPadded.^2 .* ( ...
                    obj.absorbTauPadded .* fracLaplacian(obj, obj.medium.densityPadded .* sum(divergence(obj.velocityPadded),4), obj.medium.absorptionPower/2 -1 ) + ...
                    obj.absorbEtaPadded .* fracLaplacian(obj, sum(obj.densitySplitPadded,4), obj.medium.absorptionPower/2 -0.5 ) ) ;
            end

            if strcmp(obj.BoundCond,'on')
                obj.pressurePadded = obj.BoundaryCondition.applyBoundaryCondition(obj.pressurePadded);
            end
        
        else

            % Momentum conservation equation.
            obj.velocityPadded = pmlSG(pmlSG(obj.velocityPadded) - (dt ./ densityPaddedStg) .* gradient(obj.pressurePadded));

            % Mass conservation equation.
            obj.densitySplitPadded = pml(pml(obj.densitySplitPadded) - dt .* obj.medium.densityPadded .* divergence(obj.velocityPadded));

            % Pressure density relation.
            obj.pressurePadded = obj.medium.soundSpeedPadded.^2 .* ( sum(obj.densitySplitPadded, 4));

            % If absorptionPower declaired then add absorption terms
            if ~strcmp(obj.absorptionType,'off')
                obj.pressurePadded =  obj.pressurePadded  +  obj.medium.soundSpeedPadded.^2 .* ( ...
                    obj.absorbTauPadded .* fracLaplacian(obj, obj.medium.densityPadded .* sum(divergence(obj.velocityPadded),4), obj.medium.absorptionPower/2 -1 ) + ...
                    obj.absorbEtaPadded .* fracLaplacian(obj, sum(obj.densitySplitPadded,4), obj.medium.absorptionPower/2 -0.5 ) ) ;
            end
            if strcmp(obj.BoundCond,'on')
                obj.pressurePadded = obj.BoundaryCondition.applyBoundaryCondition(obj.pressurePadded);
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


