%% SetAbsorptionCoefficients
% *Class:* kwave.toolbox.AcosticSolver
% *Package:* kwave.toolbox
%
% Compute and assign the coefficents tau and eta in the fractional laplacian loss.
%
%% Syntax
%   setabsorptioncoefficients(obj)
%
%% Description
% Compute and assign the coefficents tau and eta in the fractional,
% assigns values as given by the formula in: 
% Treeby, Bradley E., and Ben T. Cox. 
%    "Modeling power law absorption and dispersion for acoustic propagation using the fractional Laplacian." 
%     The Journal of the Acoustical Society of America 127.5 (2010): 2741-2748.
%
% If no dispersion, problem reduces with eta=0
% If no absorption, problem reduces with tau=0
% 'noDispersion' or 'noAbsorption' or 'on' must be declaired by setting 
% AcousticSolver.absorptionType
%
% If absorptionPower=0, 2, problem reduces.
%
% |obj.prevTimeStep|, the k-space correction is adjusted to account for the
% change in time step.
%
%% Input Arguments
% None
%
% Copyright (C) 2024- The k-Wave-II Authors.
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
%
%% ========================================================================

function setAbsorptionCoefficients(obj)

arguments
    obj
end
validateattributes( obj.medium.absorptionPower, {'single'}, {'scalar'})

% convert the absorption coefficient to nepers.(rad/s)^-y.m^-1
alphaCoeffPadded = 5 * obj.medium.absorptionCoeffPadded * (((1e-6)/(2*pi) )^obj.medium.absorptionPower ) / (log10(exp(1)));

% Applies Formula, sets eta to 0 is applicable
if strcmp(obj.absorptionType,'noDispersion') || obj.medium.absorptionPower ==0 || obj.medium.absorptionPower==2
    obj.absorbEtaPadded =0;
else
    obj.absorbEtaPadded =   -2 .* alphaCoeffPadded .* obj.medium.soundSpeedPadded.^(obj.medium.absorptionPower    ) .* tan(pi .* obj.medium.absorptionPower  / 2);
end

% Applies Formula, sets tau to 0 is applicable
if strcmp(obj.absorptionType,'noAbsorption')
    obj.absorbTauPadded = 0;
else
    obj.absorbTauPadded =  -2 .* alphaCoeffPadded .* obj.medium.soundSpeedPadded.^(obj.medium.absorptionPower  - 1);
end

end


