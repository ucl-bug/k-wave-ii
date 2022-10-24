%% highestPrimeFactors
% *Class:* kwave.toolbox.kWaveGrid
% *Package:* kwave.toolbox
%
% Calculate highest prime factors.
%
%% Syntax
%   kgrid = kWaveGrid([32, 31], 1e-3);
%   primeFacs = kgrid.highestPrimeFactors;
%
%% Description
% Calculates the highest prime factors for each grid dimension.

function primeFacs = highestPrimeFactors(obj)

primeFacs = [max(factor(obj.Nx)), max(factor(obj.Ny)), max(factor(obj.Nz))];
