%% divergence
% *Class:* kwave.toolbox.FourierCollocation
% *Package:* kwave.toolbox
%
% Calculate divergence of vector field.
%
%% Syntax
%   df = divergence(obj, f)
%   df = divergence(obj, f, Staggering='forward')
%
%% Description
% Calculates the divergence of a vector field in 1D, 2D, or 3D using a
% Fourier collocation spectral method.
% 
% The vector components of the input field are stacked in the 4th
% dimension. For example, if calling divergence on a vector field in 2D,
% the input should have dimensions (Nx, Ny, 1, 2), while the output will
% have size (Nx, Ny). This is to allow codes to implement multi-dimensional
% support by always looping over the fourth dimension.
%
% If obj.kappa is defined, a k-space correction is applied as part of the
% divergence calulation. If kappa is a scalar (single frequency correction)
% or empty, the contributions to the divergence for each of the Cartesian
% coordinates are calculated using 1D FFTs. If kappa is a matrix, they are
% calculated using ND FFTs, and kappa is applied in the Fourier domain.
%
% The divergence operations (and kappa if defined) are defined on the
% padded grid. Thus, the inputs to this function must also be defined on
% the padded grid. The output can be returned on a spatially staggered grid
% by setting the optional |Staggering| argument.
%
%% Input Arguments
% * |f| - (numeric) Vector field to compute divergence of.
%
%% Name-Value Arguments
% Specify optional pairs of arguments as |Name1=Value1,...,NameN=ValueN|,
% where |Name| is the argument name and |Value| is the corresponding value.
% Name-value arguments must appear after other arguments, but the order of
% the pairs does not matter.
%
% * |Staggering| - ('none', 'forward', 'backward') Option to return the
%   output staggered by half a grid point in the specified direction.
%   Defatult = 'none'.
%
%% Output Arguments
% * |df| - (numeric) Divergence of f.

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

function f = divergence(obj, f, varargin)

% Calculate components of divergence, and then sum them. Devolve input
% checking to divergenceSplit.
f = sum(obj.divergenceSplit(f, varargin{:}), 4);
