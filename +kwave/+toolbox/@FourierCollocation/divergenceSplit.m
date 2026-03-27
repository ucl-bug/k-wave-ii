%% Divergence Split
% *Class:* kwave.toolbox.FourierCollocation
% *Package:* kwave.toolbox
%
% Calculate components of divergence of vector field.
%
%% Syntax
%   df = divergenceSplit(obj, f)
%   df = divergenceSplit(obj, f, Staggering='forward')
%
%% Description
% Calculates the split components (e.g., dfx/dx, dfy/dy) of the divergence
% of a vector field in 1D, 2D, or 3D using a Fourier collocation spectral
% method. This is equivalent to the diagonal of the vector gradient.
% 
% The vector components of the input field, and the split components of the
% divergence, are stacked in the 4th dimension. For example, if calling
% divergence on a vector field in 2D, the input should have dimensions (Nx,
% Ny, 1, 2), and the output will be the same size. This is to allow codes
% to implement multi-dimensional support by always looping over the fourth
% dimension.
%
% If |obj.kappa| is defined, a k-space correction is applied as part of the
% divergence calculation. If kappa is a scalar (single frequency correction)
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
%   Default = 'none'.
%
%% Output Arguments
% * |df| - (numeric) Components of divergence of f.

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


function f = divergenceSplit(obj, f, options)
% Note: operations can be performed in-place, so we don't allocate a
% separate output variable.

arguments
    obj
    f(:,:,:,:)
    options.Staggering(1,:) char {mustBeMember(options.Staggering, {'none', 'forward', 'backward'})} = 'none'
end

% Check input dimensions.
if obj.dimensions ~= size(f, 4)
    kwave.toolbox.Logger.error('FourierCollocation:incorrectSize', ['Input must be vector field with ' num2str(obj.dimensions) ' components.']);
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

% Scalar or no k-space correction, so use 1D FFTs.
if isempty(obj.kappa) || isscalar(obj.kappa)
    for dimInd = 1:obj.dimensions
        switch dimInd
            case 1
                f(:, :, :, 1) = ifft(ddx .* fft(f(:, :, :, 1), [], 1), [], 1, 'symmetric');
            case 2
                f(:, :, :, 2) = ifft(ddy .* fft(f(:, :, :, 2), [], 2), [], 2, 'symmetric');
            case 3
                f(:, :, :, 3) = ifft(ddz .* fft(f(:, :, :, 3), [], 3), [], 3, 'symmetric');
        end
    end

    if isscalar(obj.kappa)
        f = f .* obj.kappa;
    end

% ND k-space correction, so use ND FFTs.
else
    for dimInd = 1:obj.dimensions
        switch dimInd
            case 1
                f(:, :, :, 1) = ifftn(ddx .* obj.kappa .* fftn(f(:, :, :, 1)), 'symmetric');
            case 2
                f(:, :, :, 2) = ifftn(ddy .* obj.kappa .* fftn(f(:, :, :, 2)), 'symmetric');
            case 3
                f(:, :, :, 3) = ifftn(ddz .* obj.kappa .* fftn(f(:, :, :, 3)), 'symmetric');
        end
    end
end
