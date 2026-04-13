%% Scale SI
% *Package:* kwave.utilities
%
% Scale a number to the nearest SI unit prefix.
%
%% Syntax
%   xScaled = scaleSI(x)
%   [xScaled, scale] = scaleSI(x)
%   [xScaled, scale, prefix] = scaleSI(x)
%   [xScaled, scale, prefix, prefixFullName] = scaleSI(x)
%
%% Description
% |scaleSI| scales the input x to use the nearest SI unit prefix while
% keeping 1000 > x > 1. This function aids in representing large or small
% numbers in a more readable format by attaching appropriate SI prefixes
% such as kilo, mega, milli, micro, etc., and scaling the number
% accordingly.
%
%% Examples
%   % Scale a large number
%   x = 5000000;
%   xScaled = scaleSI(x);
%   disp(xScaled);
%
%   % Scale a small number
%   x = 0.0005;
%   xScaled = scaleSI(x);
%   disp(xScaled);
%
%% Input Arguments
% * |x| - (numeric) The number to be scaled. The function will find the
%   most appropriate SI prefix to scale the number, keeping it between 1
%   and 1000.
%
%% Output Arguments
% * |xScaled| - (string) Scaled input represented as a string, concatenated
%   with the SI prefix.
% * |scale| - (double) Numeric scale factor used to scale the input.
% * |prefix| - (char) Single character representing the SI prefix used for
%   scaling.
% * |prefixFullName| - (string) Full SI name for the prefix used in
%   scaling.
%
%% See Also
% * |kwave.utilities.formatDuration|

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

function [xScaled, scale, prefix, prefixFullName] = scaleSI(x)

% Force the input to be a scalar.
x = max(x(:));

% Check for a negative input.
if x < 0
    x = -x;
    negative = true;
else
    negative = false;
end

if x == 0
    
    % If x is zero, don't scale.
    xScaled = x;
    prefix = '';
    prefixFullName = '';
    scale = 1;
    
elseif x < 1
    
    % Update index and input.
    xScaled = x * 1e3;
    symbolIndex = 1;
       
    % Find scaling parameter.
    while xScaled < 1 && symbolIndex < 8
        xScaled = xScaled * 1e3;
        symbolIndex = symbolIndex + 1;
    end

    % Define SI unit scalings.
    switch symbolIndex
        case 1
            prefix = 'm';
            prefixFullName = 'milli';
            scale = 1e3;
        case 2
            prefix = 'u';
            prefixFullName = 'micro';
            scale = 1e6;
        case 3
            prefix = 'n';
            prefixFullName = 'nano';
            scale = 1e9;
        case 4
            prefix = 'p';
            prefixFullName = 'pico';
            scale = 1e12;
        case 5
            prefix = 'f';
            prefixFullName = 'femto';
            scale = 1e15;
        case 6
            prefix = 'a';
            prefixFullName = 'atto';
            scale = 1e18;
        case 7
            prefix = 'z';
            prefixFullName = 'zepto';
            scale = 1e21;
        case 8
            prefix = 'y';
            prefixFullName = 'yocto';
            scale = 1e24;
    end    
    
elseif x >= 1000
    
    % Update index and input.
    xScaled = x * 1e-3;
    symbolIndex = 1;
    
    % Find scaling parameter.
    while xScaled >= 1000 && symbolIndex < 8
        xScaled = xScaled * 1e-3;
        symbolIndex = symbolIndex + 1;
    end
        
    % Define SI unit scalings.
    switch symbolIndex
        case 1
            prefix = 'k';
            prefixFullName = 'kilo';
            scale = 1e-3;
        case 2
            prefix = 'M';
            prefixFullName = 'mega';
            scale = 1e-6;
        case 3
            prefix = 'G';
            prefixFullName = 'giga';
            scale = 1e-9;
        case 4
            prefix = 'T';
            prefixFullName = 'tera';
            scale = 1e-12;
        case 5
            prefix = 'P';
            prefixFullName = 'peta';
            scale = 1e-15;
        case 6
            prefix = 'E';
            prefixFullName  = 'exa';
            scale = 1e-18;
        case 7
            prefix = 'Z';
            prefixFullName = 'zetta';
            scale = 1e-21;
        case 8
            prefix = 'Y';
            prefixFullName = 'yotta';
            scale = 1e-24;
    end
    
else
    
    % If x is between 1 and 1000, don't scale.
    xScaled = x;
    prefix = '';
    prefixFullName = '';
    scale = 1;
    
end

% Form scaling into a string.
if negative
    xScaled = ['-', num2str(xScaled), prefix];
else
    xScaled = [num2str(xScaled), prefix];
end
