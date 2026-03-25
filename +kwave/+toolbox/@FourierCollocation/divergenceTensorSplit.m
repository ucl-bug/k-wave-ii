%% divergenceTensorSplit
% *Class:* kwave.toolbox.FourierCollocation
% *Package:* kwave.toolbox
%
% Calculate the divergence of a tensor field.
%
%% Syntax
%   ds = divergenceTensorSplit(obj, s)
%   ds = divergenceTensorSplit(obj, s, Staggering='forward')
%
%% Description
% Calculates the divergence of a symmetric tensor in 1D, 2D, or 3D using a
% Fourier collocation spectral method.  The symmetric tensor must be
% linearised to a vector of dimensions % [D * (D + 1) / 2 , 1] where the 
% components are [sxx] in 1D, [sxx, syy, sxy]' in 2D and 
% [sxx, syy, szz, sxy, sxz, syz]' in 3D.
%
% The partial derivatives of the symmetric tensor which are non-zero are
%     ds = [dsxxdx, dsxydy, dsxzdz;
%           dsxydx, dsyydy, dsyzdz;
%           dsxzdx, dsyzdy, dszzdz]
% 
% The tensor components of the divergence are stacked in the 4th and 5th
% dimension of the output. For example, if calling divergenceTensorSplit
% on a matrix of dimensions (10, 10), the output will be of size
% (10, 10, 1, 2, 2).  This is to allow codes to implement multi-dimensional
% support by always looping over the fourth and fifth dimensions.
%
% If obj.kappa is defined, a k-space correction is applied as part of the
% divergence calculation. If kappa is a scalar (single frequency correction)
% or empty, the divergence components are calculated using 1D FFTs. If kappa
% is a matrix, the divergence components are calculated using ND FFTs, and
% kappa is applied in the Fourier domain.
% 
% The divergence operations (and kappa if defined) are defined on the padded
% grid. Thus, the inputs to this function must also be defined on the
% padded grid. The output can be returned on a spatially staggered grid by
% setting the optional |Staggering| argument.
%
%% Input Arguments
% * |s| - (numeric) Tensor field to compute the split divergence of.
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
% * |ds| - (numeric) split divergence of the tensor field s.

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

function ds = divergenceTensorSplit(obj, s, options)

arguments
    obj
    s(:,:,:,:)
    options.Staggering(1,:) char {mustBeMember(options.Staggering, {'none', 'forward', 'backward'})} = 'none'
end

% Check input dimensions.
expectedSize = obj.dimensions * (obj.dimensions + 1) / 2;
if expectedSize ~= size(s, 4)
    kwave.toolbox.Logger.error('FourierCollocation:incorrectSize', ['Input must be vector field with ' num2str(expectedSize) ' components.']);
end

% Assign pseudonym for k-space derivative and shift operator.
switch options.Staggering
    case 'none'
        dsxxdx = obj.ddxNoShift;
        dsxydy = obj.ddyNoShift;
        dsxzdz = obj.ddzNoShift;
        dsxydx = obj.ddxNoShift;
        dsyydy = obj.ddyNoShift;
        dsyzdz = obj.ddzNoShift;
        dsxzdx = obj.ddxNoShift;
        dsyzdy = obj.ddyNoShift;
        dszzdz = obj.ddzNoShift;
    case 'forward'
        dsxxdx = obj.ddxShiftPos;
        dsxydy = obj.ddyShiftNeg;
        dsxzdz = obj.ddzShiftNeg;
        dsxydx = obj.ddxShiftNeg;
        dsyydy = obj.ddyShiftPos;
        dsyzdz = obj.ddzShiftNeg;
        dsxzdx = obj.ddxShiftNeg;
        dsyzdy = obj.ddyShiftNeg;
        dszzdz = obj.ddzShiftPos;
    case 'backward'
        dsxxdx = obj.ddxShiftNeg;
        dsxydy = obj.ddyShiftPos;
        dsxzdz = obj.ddzShiftPos;
        dsxydx = obj.ddxShiftPos;
        dsyydy = obj.ddyShiftNeg;
        dsyzdz = obj.ddzShiftPos;
        dsxzdx = obj.ddxShiftPos;
        dsyzdy = obj.ddyShiftPos;
        dszzdz = obj.ddzShiftNeg;
end

% Preallocate output matrix (vector field).
ds = zeros([obj.kgridPadded.gridSize, obj.dimensions, obj.dimensions]);

% Scalar or no k-space correction, so use 1D FFTs.
if isempty(obj.kappa) || isscalar(obj.kappa)
    for dimInd = 1:obj.dimensions
        switch dimInd
            case 1
                ds(:, :, :, 1, 1) = ifft(dsxxdx .* fft(s(:, :, :, 1), [], 1), [], 1, 'symmetric');
            case 2
                ds(:, :, :, 2, 2) = ifft(dsyydy .* fft(s(:, :, :, 2), [], 2), [], 2, 'symmetric');
                if obj.dimensions == 2
                    ds(:, :, :, 2, 1) = ifft(dsxydx .* fft(s(:, :, :, 3), [], 1), [], 1, 'symmetric');
                    ds(:, :, :, 1, 2) = ifft(dsxydy .* fft(s(:, :, :, 3), [], 2), [], 2, 'symmetric');
                elseif obj.dimensions == 3
                    ds(:, :, :, 2, 1) = ifft(dsxydx .* fft(s(:, :, :, 4), [], 1), [], 1, 'symmetric');
                    ds(:, :, :, 1, 2) = ifft(dsxydy .* fft(s(:, :, :, 4), [], 2), [], 2, 'symmetric');
                end
            case 3
                ds(:, :, :, 3, 3) = ifft(dszzdz .* fft(s(:, :, :, 3), [], 3), [], 3, 'symmetric');
                ds(:, :, :, 3, 1) = ifft(dsxzdx .* fft(s(:, :, :, 5), [], 1), [], 1, 'symmetric');
                ds(:, :, :, 1, 3) = ifft(dsxzdz .* fft(s(:, :, :, 5), [], 3), [], 3, 'symmetric');
                ds(:, :, :, 3, 2) = ifft(dsyzdy .* fft(s(:, :, :, 6), [], 2), [], 2, 'symmetric');
                ds(:, :, :, 2, 3) = ifft(dsyzdz .* fft(s(:, :, :, 6), [], 3), [], 3, 'symmetric');
        end
    end

    if isscalar(obj.kappa)
        ds = ds .* obj.kappa;
    end

% ND k-space correction, so use ND FFTs.
else
    for dimInd = 1:obj.dimensions
        switch dimInd
            case 1
                ds(:, :, :, 1, 1) = ifftn(dsxxdx .* obj.kappa .* fftn(s(:, :, :, 1)), 'symmetric');
            case 2
                ds(:, :, :, 2, 2) = ifftn(dsyydy .* obj.kappa .* fftn(s(:, :, :, 2)), 'symmetric');
                if obj.dimensions == 2
                    ds(:, :, :, 2, 1) = ifftn(dsxydx .* obj.kappa .* fftn(s(:, :, :, 3)), 'symmetric');
                    ds(:, :, :, 1, 2) = ifftn(dsxydy .* obj.kappa .* fftn(s(:, :, :, 3)), 'symmetric');
                elseif obj.dimensions == 3
                    ds(:, :, :, 2, 1) = ifftn(dsxydx .* obj.kappa .* fftn(s(:, :, :, 4)), 'symmetric');
                    ds(:, :, :, 1, 2) = ifftn(dsxydy .* obj.kappa .* fftn(s(:, :, :, 4)), 'symmetric');
                end
            case 3
                ds(:, :, :, 3, 3) = ifftn(dszzdz .* obj.kappa .* fftn(s(:, :, :, 3)), 'symmetric');
                ds(:, :, :, 3, 1) = ifftn(dsxzdx .* obj.kappa .* fftn(s(:, :, :, 5)), 'symmetric');
                ds(:, :, :, 1, 3) = ifftn(dsxzdz .* obj.kappa .* fftn(s(:, :, :, 5)), 'symmetric');
                ds(:, :, :, 3, 2) = ifftn(dsyzdy .* obj.kappa .* fftn(s(:, :, :, 6)), 'symmetric');
                ds(:, :, :, 2, 2) = ifftn(dsyzdz .* obj.kappa .* fftn(s(:, :, :, 6)), 'symmetric');
        end
    end
end
