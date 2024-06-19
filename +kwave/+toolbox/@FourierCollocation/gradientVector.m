%% gradient
% *Class:* kwave.toolbox.FourierCollocation
% *Package:* kwave.toolbox
%
% Calculate gradient of vector field.
%
%% Syntax
%   df = gradientVector(obj, f)
%   df = gradientVector(obj, f, Staggering='forward')
%
%% Description
% Calculates the gradient of a vector field in 1D, 2D, or 3D using a
% Fourier collocation spectral method.
% 
% The tensor components of the gradient are stacked in the 4th and 5th
% dimensions of the output. For example, if calling gradient on a matrix
% of dimensions (10, 10), the output will be of size (10, 10, 1, 2, 2).
% This is to allow codes to implement multi-dimensional support by always
% looping over the fourth and fifth dimensions.
%
% The resulting tensor takes the shape
%   df = [dfxdx dfxdy dfxdz;
%         dfydx dfydy dfydz;
%         dfzdx dfzdy dfzdz]
%
% If obj.kappa is defined, a k-space correction is applied as part of the
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
% * |f| - (numeric) Vector field to compute gradient of.
%
%% Name-Value Arguments
% Specify optional pairs of arguments as |Name1=Value1,...,NameN=ValueN|,
% where |Name| is the argument name and |Value| is the corresponding value.
% Name-value arguments must appear after other arguments, but the order of
% the pairs does not matter.
%
% * |Staggering| - ('none', 'forward', 'backward') Option to return the
%   output staggered by half a grid point in the specified direction.
%   Default  = 'none'.
%
%% Output Arguments
% * |df| - (numeric) Gradient of f.

% Copyright (C) 2024- University College London.
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

function df = gradientVector(obj, f, options)

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
        dfxdx = obj.ddxNoShift;
        dfxdy = obj.ddyNoShift;
        dfxdz = obj.ddzNoShift;
        dfydx = obj.ddxNoShift;
        dfydy = obj.ddyNoShift;
        dfydz = obj.ddzNoShift;
        dfzdx = obj.ddxNoShift;
        dfzdy = obj.ddyNoShift;
        dfzdz = obj.ddzNoShift;
    case 'forward'
        dfxdx = obj.ddxShiftPos;
        dfxdy = obj.ddyShiftNeg;
        dfxdz = obj.ddzShiftNeg;
        dfydx = obj.ddxShiftNeg;
        dfydy = obj.ddyShiftPos;
        dfydz = obj.ddzShiftNeg;
        dfzdx = obj.ddxShiftNeg;
        dfzdy = obj.ddyShiftNeg;
        dfzdz = obj.ddzShiftPos;
    case 'backward'
        dfxdx = obj.ddxShiftNeg;
        dfxdy = obj.ddyShiftPos;
        dfxdz = obj.ddzShiftPos;
        dfydx = obj.ddxShiftPos;
        dfydy = obj.ddyShiftNeg;
        dfydz = obj.ddzShiftPos;
        dfzdx = obj.ddxShiftPos;
        dfzdy = obj.ddyShiftPos;
        dfzdz = obj.ddzShiftNeg;
end

% Preallocate output matrix (tensor field).
df = zeros([obj.kgridPadded.gridSize, obj.dimensions, obj.dimensions]);

% Scalar or no k-space correction, so use 1D FFTs.
if isempty(obj.kappa) || isscalar(obj.kappa)
    for dimInd = 1:obj.dimensions
        switch dimInd
            case 1
                df(:, :, :, 1, 1) = ifft(dfxdx .* fft(f(:, :, :, 1), [], 1), [], 1, 'symmetric');
            case 2
                df(:, :, :, 2, 1) = ifft(dfydx .* fft(f(:, :, :, 2), [], 1), [], 1, 'symmetric');
                df(:, :, :, 1, 2) = ifft(dfxdy .* fft(f(:, :, :, 1), [], 2), [], 2, 'symmetric');
                df(:, :, :, 2, 2) = ifft(dfydy .* fft(f(:, :, :, 2), [], 2), [], 2, 'symmetric');
            case 3
                df(:, :, :, 3, 1) = ifft(dfzdx .* fft(f(:, :, :, 3), [], 1), [], 1, 'symmetric');
                df(:, :, :, 3, 2) = ifft(dfzdy .* fft(f(:, :, :, 3), [], 2), [], 2, 'symmetric');
                df(:, :, :, 1, 3) = ifft(dfxdz .* fft(f(:, :, :, 1), [], 3), [], 3, 'symmetric');
                df(:, :, :, 2, 3) = ifft(dfydz .* fft(f(:, :, :, 2), [], 3), [], 3, 'symmetric');
                df(:, :, :, 3, 3) = ifft(dfzdz .* fft(f(:, :, :, 3), [], 3), [], 3, 'symmetric');
        end
    end

    if isscalar(obj.kappa)
        df = df .* obj.kappa;
    end

% ND k-space correction, so use ND FFTs.
else
    for dimInd = 1:obj.dimensions
        switch dimInd
            case 1
                df(:, :, :, 1, 1) = ifftn(dfxdx .* obj.kappa .* fftn(f(:, :, :, 1)), 'symmetric');
            case 2
                df(:, :, :, 2, 1) = ifftn(dfydx .* obj.kappa .* fftn(f(:, :, :, 2)), 'symmetric');
                df(:, :, :, 1, 2) = ifftn(dfxdy .* obj.kappa .* fftn(f(:, :, :, 1)), 'symmetric');
                df(:, :, :, 2, 2) = ifftn(dfydy .* obj.kappa .* fftn(f(:, :, :, 2)), 'symmetric');
            case 3
                df(:, :, :, 3, 1) = ifftn(dfzdx .* obj.kappa .* fftn(f(:, :, :, 3)), 'symmetric');
                df(:, :, :, 3, 2) = ifftn(dfzdy .* obj.kappa .* fftn(f(:, :, :, 3)), 'symmetric');
                df(:, :, :, 1, 3) = ifftn(dfxdz .* obj.kappa .* fftn(f(:, :, :, 1)), 'symmetric');
                df(:, :, :, 2, 2) = ifftn(dfydz .* obj.kappa .* fftn(f(:, :, :, 2)), 'symmetric');
                df(:, :, :, 3, 3) = ifftn(dfzdz .* obj.kappa .* fftn(f(:, :, :, 3)), 'symmetric');
        end
    end
end
