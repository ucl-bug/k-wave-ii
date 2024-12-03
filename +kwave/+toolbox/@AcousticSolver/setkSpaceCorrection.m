%% setkSpaceCorrection
% *Class:* kwave.toolbox.AcousticSolver
% *Package:* kwave.toolbox
%
% Compute and assign the k-space dispersion correction.
%
%% Syntax
%   setkSpaceCorrection(obj, dt)
%
%% Description
% Computes the k-space dispersion correction for the wave equation and
% assigns this to obj.kappa. The calculation is based on
% |obj.medium.soundSpeedReference|. If |dt| is not equal to
% |obj.prevTimeStep|, the k-space correction is adjusted to account for the
% change in time step.
%
%% Input Arguments
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

function setkSpaceCorrection(obj, dt)

arguments
    obj
    dt(1,1) single {mustBeNumeric, mustBePositive, mustBeFinite}
end

ck = obj.medium.soundSpeedReference * obj.kgridPadded.k;

if (dt ~= obj.prevTimeStep)
    dt1 = dt;
    dt2 = obj.prevTimeStep;
    obj.kappa = ifftshift(2i * (exp(-1i * ck * dt2/2) - exp(1i * ck * dt1/2)) ./ (ck * (dt1 + dt2)));
    obj.kappa(isnan(obj.kappa)) = 1;
else
    obj.kappa = ifftshift(kwave.toolbox.FourierCollocation.sinc(ck * dt/2));
end