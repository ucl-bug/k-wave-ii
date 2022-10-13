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

function primeFacs = highestPrimeFactors(obj, axisymmetric)

if nargin == 2
    switch axisymmetric
        case 'WSWA'
            primeFacs = [max(factor(obj.Nx)), max(factor(obj.Ny * 4)), max(factor(obj.Nz))];
        case 'WSWS'
            primeFacs = [max(factor(obj.Nx)), max(factor(obj.Ny * 2 - 2)), max(factor(obj.Nz))];
        otherwise
            error('kWaveGrid:unknownInput', 'Unknown axisymmetric symmetry.');
    end
else
    primeFacs = [max(factor(obj.Nx)), max(factor(obj.Ny)), max(factor(obj.Nz))];
end
