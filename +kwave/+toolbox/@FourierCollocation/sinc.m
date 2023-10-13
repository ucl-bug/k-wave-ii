%% sinc
% *Class:* kwave.toolbox.FourierCollocation
% *Package:* kwave.toolbox
%
% Sin(x)/x function.
%
%% Syntax
%   y = sinc(x)
%
%% Description
% Computes y = sin(x)/x. Differs from MATLAB's internal
% |<matlab:doc('sinc') sinc>| function which computes y = sin(pi*x)/(pi*x).
%
%% Input Arguments
% * |x| - (numeric) Input.
%
%% Output Arguments
% * |y| - (numeric) sin(x)/x.

% Copyright (C) 2022- University College London.
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

function y = sinc(x)

zero_vals = (x == 0);
y = sin(x + pi * zero_vals) ./ (x + zero_vals) + zero_vals;
