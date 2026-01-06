%% Fractional Laplacian
% *Class:* kwave.toolbox.FourierCollocation
% *Package:* kwave.toolbox
%
% Calculate fractionLaplacian of scalar field for a given power.
%
%% Syntax
%   ddf = fracLaplacian(obj, f,y)
%   ddf = fracLaplacian(obj, f,y,Staggering='forward')
%
%% Description
% Calculates the gradient of a scalar field in 1D, 2D, or 3D using a
% Fourier collocation spectral method.
% 
% The vector components of the gradient are stacked in the 4th dimension of
% the output. For example, if calling gradient on a matrix of dimensions
% (10, 10), the output will be of size (10, 10, 1, 2). This is to allow
% codes to implement multi-dimensional support by always looping over the
% fourth dimension.
% 
% If y==0, the function returns the original function. 
% If y==2, the function returns the traditional laplacian.
%
%% Input Arguments
% * |f| - (numeric) Scalar field to compute gradient of.
% * |y| - (numeric) scalar value for power of fractional Laplacian
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
% * |df| - (numeric) Fractional Laplacian of f.


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

function ddf = fracLaplacian(obj, f,y, options)

%Computes (-Nab^2)^y through the Fourier Collication method

arguments
    obj
    f(:,:,:,1)
    y single
    options.Staggering(1,:) char {mustBeMember(options.Staggering, {'none', 'forward', 'backward'})} = 'none'
end

% Assign pseudonym for k-space derivative and shift operator.
switch options.Staggering
    case 'none'
        xshift=1;
        yshift=1;
        zshift=1;
    case 'forward'
        xshift= reshape(ifftshift(exp( 1i.*obj.kgridPadded.kxVec * obj.kgridPadded.dx/2)), [], 1, 1);
        yshift= reshape(ifftshift(exp( 1i.*obj.kgridPadded.kyVec * obj.kgridPadded.dy/2)), 1, [], 1);
        zshift= reshape(ifftshift(exp( 1i.*obj.kgridPadded.kzVec * obj.kgridPadded.dz/2)), 1, 1, []);
    case 'backward'
        xshift= reshape(ifftshift(exp(-1i.*obj.kgridPadded.kxVec * obj.kgridPadded.dx/2)), [], 1, 1);
        yshift= reshape(ifftshift(exp(-1i.*obj.kgridPadded.kyVec * obj.kgridPadded.dy/2)), 1, [], 1);
        zshift= reshape(ifftshift(exp(-1i.*obj.kgridPadded.kzVec * obj.kgridPadded.dz/2)), 1, 1, []);
end

dLap=ifftshift(obj.kgridPadded.k.^(2*y));
dLap(isinf(dLap))=0;

% ND k-space derivative
ddf = ifftn(dLap .*xshift.*yshift.*zshift.* fftn(f), 'symmetric');


