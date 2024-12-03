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
    Nt(1,1) {mustBeInteger, mustBePositive, mustBeFinite}
    dt(1,1) {mustBeNumeric, mustBePositive, mustBeFinite}
end

% Set k-space correction (depends on time step).
obj.kappa = ifftshift(kwave.toolbox.FourierCollocation.sinc(obj.medium.soundSpeedReference * obj.kgridPadded.k * dt/2));

%
if ~isempty(obj.medium.absorptionPower)
setAbsorptionCoefficients(obj)
end

% Set PML variables (depend on time step).
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

for tIndex = 1:Nt

    if (obj.timeStepsTaken == 0)

        % Set initial conditions for a photoacoustic initial value problem.
        % We do this here, rather than in setInitialConditions, as setting
        % the initial particle velocity requires the time step. The
        % calculated density term is automatically copied to all components
        % of densitySplit via implicit expansion.
        obj.pressurePadded = obj.source.initialPressurePadded;
        obj.densitySplitPadded = obj.densitySplitPadded + obj.source.initialPressurePadded ./ (obj.dimensions * obj.medium.soundSpeedPadded.^2);
        obj.velocityPadded = (dt ./ densityPaddedStg) .* gradient(obj.pressurePadded) / 2;
    else

        % Momentum conservation equation.
        obj.velocityPadded = pmlSG(pmlSG(obj.velocityPadded) - (dt ./ densityPaddedStg) .* gradient(obj.pressurePadded));

        % Mass conservation equation.
        obj.densitySplitPadded = pml(pml(obj.densitySplitPadded) - dt .* obj.medium.densityPadded .* divergence(obj.velocityPadded));
        
        % Pressure density relation.
        obj.pressurePadded = obj.medium.soundSpeedPadded.^2 .* ( sum(obj.densitySplitPadded, 4));

        % If absorptionPower declaired then add absorption terms
        if ~isempty(obj.medium.absorptionPower)
            obj.pressurePadded =  obj.pressurePadded  +  obj.medium.soundSpeedPadded.^2 .* ( ...
                obj.absorbTauPadded .* fracLaplacian(obj, obj.medium.densityPadded .* sum(divergence(obj.velocityPadded),4), obj.medium.absorptionPower/2 -1 ) + ...
                obj.absorbEtaPadded .* fracLaplacian(obj, sum(obj.densitySplitPadded,4), obj.medium.absorptionPower/2 -0.5 ) ) ;
        end

    end

    % Plot.
    if obj.settings.plotSimulation && (rem(tIndex, obj.settings.plotFrequency) == 0 || tIndex == 1 || tIndex == Nt)
        figure(fig);
        obj.plotField(obj.pressure);
    end

    obj.timeStepsTaken = obj.timeStepsTaken + 1;
end
