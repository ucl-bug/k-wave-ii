%% gradient
% *Class:* kwave.toolbox.FourierCollocation
% *Package:* kwave.toolbox
%
% Calculate gradient of scalar field.
%
%% Syntax
%   df = gradient(obj, f)
%   df = gradient(obj, f, Staggering='forward')
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
% If |obj.kappa| is defined, a k-space correction is applied as part of the
% gradient calculation. If kappa is a scalar (single frequency correction)
% or empty, the gradient components are calculated using 1D FFTs. If kappa
% is a matrix, the gradient components are calculated using ND FFTs, and
% kappa is applied in the Fourier domain.
%
% The gradient operations (and kappa if defined) are defined on the padded
% grid. Thus, the inputs to this function must also be defined on the
% padded grid. The output can be returned on a spatially staggered grid by
% setting the optional |Staggering| argument.
%
%% Input Arguments
% * |f| - (numeric) Scalar field to compute gradient of.
%
%% Name-Value Arguments
% Specify optional pairs of arguments as |Name1=Value1,...,NameN=ValueN|,
% where |Name| is the argument name and |Value| is the corresponding value.
% Name-value arguments must appear after other arguments, but the order of
% the pairs does not matter.
%
% * |Staggering| - ('none', 'forward', 'backward') Option to return the
%   output staggered by half a grid point in the specified direction.
%   Default = 'none'.
%
%% Output Arguments
% * |df| - (numeric) Gradient of f.

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


function df = gradient(obj, f, options)

arguments
    obj
    f(:,:,:,1)
    options.Staggering(1,:) char {mustBeMember(options.Staggering, {'none', 'forward', 'backward'})} = 'none'
end

% Assign pseudonym for k-space derivative and shift operator.
switch options.Staggering
    case 'none'
        ddx = obj.ddxNoShift;
        ddy = obj.ddyNoShift;
        ddz = obj.ddzNoShift;
    case 'forward'
        ddx = obj.ddxShiftPos;
        ddy = obj.ddyShiftPos;
        ddz = obj.ddzShiftPos;
    case 'backward'
        ddx = obj.ddxShiftNeg;
        ddy = obj.ddyShiftNeg;
        ddz = obj.ddzShiftNeg;
end

% Preallocate output matrix (vector field).
df = zeros([obj.kgridPadded.gridSize, obj.dimensions]);

% Scalar or no k-space correction, so use 1D FFTs.
if isempty(obj.kappa) || isscalar(obj.kappa)
    for dimInd = 1:obj.dimensions
        switch dimInd
            case 1
                df(:, :, :, 1) = ifft(ddx .* fft(f, [], 1), [], 1, 'symmetric');
            case 2
                df(:, :, :, 2) = ifft(ddy .* fft(f, [], 2), [], 2, 'symmetric');
            case 3
                df(:, :, :, 3) = ifft(ddz .* fft(f, [], 3), [], 3, 'symmetric');
        end
    end

    if isscalar(obj.kappa)
        df = df .* obj.kappa;
    end

% ND k-space correction, so use ND FFTs.
else
    f_k = fftn(f);
    for dimInd = 1:obj.dimensions
        switch dimInd
            case 1
                df(:, :, :, 1) = ifftn(ddx .* obj.kappa .* f_k, 'symmetric');
            case 2
                df(:, :, :, 2) = ifftn(ddy .* obj.kappa .* f_k, 'symmetric');
            case 3
                df(:, :, :, 3) = ifftn(ddz .* obj.kappa .* f_k, 'symmetric');
        end
    end
end
