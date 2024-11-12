%% UPDATE =================================================================
% 
% %% Set Absoption Coefficients
% % *Class:* kwave.toolbox.AcousticAbsorptionSolver
% % *Package:* kwave.toolbox
% %
% % Compute and assign the coefficents tau and eta in the fractional laplacian loss.
% %
% %% Syntax
% %   setabsoptioncoefficients(obj)
% %
% %% Description
% % Compute and assign the coefficents tau and eta in the fractional,
% % assigns values as given by the formula in: 
% % Treeby and Cox, Modeling power law absorption and dispersion for
% %     acoustic propagation using the fractional Laplacian 2010
% %
% % If no dispersion, problem reduces with eta=0
% % If no absorption, problem reduces with tau=0
% %
% % If absorptionPower=0, 2, problem reduces.
% %
% % |obj.prevTimeStep|, the k-space correction is adjusted to account for the
% % change in time step.
% %
% %% Input Arguments
% % None
% %
% % Copyright (C) 2024- The k-Wave-II Authors.
% %
% % This file is part of k-Wave-II (http://www.k-wave.org). k-Wave-II is free
% % software: you can redistribute it and/or modify it under the terms of the
% % GNU Lesser General Public License as published by the Free Software
% % Foundation, either version 3 of the License, or (at your option) any
% % later version.
% % 
% % k-Wave-II is distributed in the hope that it will be useful, but WITHOUT
% % ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% % FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
% % License for more details.
% % 
% % You should have received a copy of the GNU Lesser General Public License
% % along with k-Wave-II. If not, see <http://www.gnu.org/licenses/>.
%
%% ========================================================================

function setabsoptioncoefficients(obj)

arguments
    obj
end

% convert the absorption coefficient to nepers.(rad/s)^-y.m^-1
alphaCoeff = db2neper(obj.medium.absorptionFactor, obj.medium.absorptionPower);

if ~strcmp(obj.medium.absorptionType,'noDispersion') && ~strcmp(obj.medium.absorptionType,'noAbsorption') && ~strcmp(obj.medium.absorptionType,'noType') && ~strcmp(obj.medium.absorptionType,'none') 
    disp('Unexpected string for absorptionType, defaulted to "noType", please use; "noDispersion", "noAbsorption", or "noType".' )
end

if strcmp(obj.medium.absorptionType,'none')
    disp('string absorptionType="none". Please run AcosuticSolver in future cases')
    obj.absorbEta =0;
    obj.absorbTau = 0;
end


% Applies Formula
if strcmp(obj.medium.absorptionType,'noDispersion') || obj.medium.absorptionPower==0 || obj.medium.absorptionPower==2 
    obj.absorbEta =0;
else
    obj.absorbEta =   -2 .* alphaCoeff .* obj.medium.soundSpeedPadded.^(obj.medium.alphaPower    ) .* tan(pi .* obj.medium.alphaPower / 2);
end


if strcmp(obj.medium.absorptionType,'noAbsorption')
     obj.absorbTau = 0;
else
    obj.absorbTau =  -2 .* alphaCoeff .* obj.medium.soundSpeedPadded.^(obj.medium.alphaPower - 1);
end


