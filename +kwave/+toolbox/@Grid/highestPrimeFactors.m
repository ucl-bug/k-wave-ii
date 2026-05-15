%% Highest Prime Factors
% *Class:* kwave.toolbox.Grid
% *Package:* kwave.toolbox
%
% Calculate highest prime factors.
%
%% Syntax
%   primeFacs = highestPrimeFactors(obj)
%
%% Description
% Calculates the highest prime factors for each grid dimension.
%
%% Examples
% Calculate the highest prime factors for a 2D grid.
%
%     kgrid = kwave.toolbox.Grid([32, 31], 1e-3);
%     kgrid.highestPrimeFactors
%     
%     ans =
%          2    31     1
%
%% Output Arguments
% * |primeFacs| - (numeric) Highest prime factor in [x, y, z].

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

function primeFacs = highestPrimeFactors(obj)

primeFacs = [max(factor(obj.Nx)), max(factor(obj.Ny)), max(factor(obj.Nz))];
