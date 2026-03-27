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

function primeFacs = highestPrimeFactors(obj)

primeFacs = [max(factor(obj.Nx)), max(factor(obj.Ny)), max(factor(obj.Nz))];
