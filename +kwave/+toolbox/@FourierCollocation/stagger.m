%% The Stagger Operation
% *Class:* kwave.toolbox.FourierCollocation
% *Package:* kwave.toolbox
%
% Shifts the input function in space, either by Fourier methods, or by linear interpolation.
%
%% Syntax
%   f = stagger(obj, f)
%   fStg = stagger(obj, f, Staggering='forward', Type='Fourier')
%
%% Description
% Calculates the staggered function of a scalar field in 1D, 2D, or 3D using a
% Fourier method, staggering in each grid spacing individually.
% 
% The vector components of the staggered field are stacked in the 4th dimension of
% the output. Staggering only in one dimension each. 
% For example, if calling stagger on a matrix of dimensions
% (10, 10), the output will be of size (10, 10, 1, 2). This is to allow
% codes to implement multi-dimensional support by always looping over the
% fourth dimension.
% 
% The stagger operations are defined on the padded grid. Thus, the inputs 
% to this function must also be defined on the padded grid. The output can 
% be returned on a spatially staggered grid by setting the optional |Staggering| 
% argument.
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
% * |Staggering| - ('forward', 'backward') Option to return the
%   output staggered by half a grid point in the specified direction.
%   Defatult = 'forward'.
% * |Type| - ('fourier', 'linInterpolate')
%
%% Output Arguments
% * |f| - (numeric) f but staggered in each co-ordinate direction.

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

function fstg = stagger(obj, f, options)

arguments
    obj
    f(:,:,:,1)
    options.Staggering(1,:) char {mustBeMember(options.Staggering, {'forward', 'backward'})} = 'forward'
    options.Type (1,:) char {mustBeMember(options.Type, {'fourier', 'linInterpolate'})} = 'fourier'
end

% Assign pseudonym for shift operator.
switch options.Type
    case 'fourier'
        switch options.Staggering
            case 'forward'
                xshift = obj.xShiftPos;
                yshift = obj.yShiftPos;
                zshift = obj.zShiftPos;
            case 'backward'
                xshift = obj.xShiftNeg;
                yshift = obj.yShiftNeg;
                zshift = obj.zShiftNeg;
        end

        % Preallocate output matrix (vector field).
        fstg = zeros([obj.kgridPadded.gridSize, obj.dimensions]);
        f_k = fftn(f);
        for dimInd = 1:obj.dimensions
            switch dimInd
                case 1 
                    fstg(:, :, :, 1) = ifftn(xshift .* f_k, 'symmetric');
                case 2
                    fstg(:, :, :, 2) = ifftn(yshift .* f_k, 'symmetric');
                case 3
                    fstg(:, :, :, 3) = ifftn(zshift .* f_k, 'symmetric');
            end
        end

    case 'linInterpolate'
        switch options.Staggering
            case 'forward'
                dimInd=obj.dimensions;
                switch dimInd
                    case 1
                        fstg(:, :, :, 1) = interpn(obj.kgridPadded.x, f, obj.kgridPadded.x + obj.kgridPadded.dx/2, '*linear');
                        fstg(isnan(fstg)) = f(isnan(fstg(:,:,:,1)));
                    case 2
                        fstg(:, :, :, 1) = interpn(obj.kgridPadded.x,obj.kgridPadded.y,  f, obj.kgridPadded.x + obj.kgridPadded.dx/2 , obj.kgridPadded.y, '*linear');
                        fstg(:, :, :, 2) = interpn(obj.kgridPadded.x,obj.kgridPadded.y,  f, obj.kgridPadded.x  , obj.kgridPadded.y + obj.kgridPadded.dy/2,  '*linear');
                        fstg(isnan(fstg)) = [f(isnan(fstg(:,:,:,1))); f(isnan(fstg(:,:,:,2)))];
                    case 3
                        fstg(:, :, :, 1) = interpn(obj.kgridPadded.x,obj.kgridPadded.y, obj.kgridPadded.z, f, obj.kgridPadded.x + obj.kgridPadded.dx/2 , obj.kgridPadded.y, obj.kgridPadded.z, '*linear');
                        fstg(:, :, :, 2) = interpn(obj.kgridPadded.x,obj.kgridPadded.y, obj.kgridPadded.z, f, obj.kgridPadded.x  , obj.kgridPadded.y + obj.kgridPadded.dy/2, obj.kgridPadded.z, '*linear');
                        fstg(:, :, :, 3) = interpn(obj.kgridPadded.x,obj.kgridPadded.y, obj.kgridPadded.z, f, obj.kgridPadded.x  , obj.kgridPadded.y , obj.kgridPadded.z + obj.kgridPadded.dz/2, '*linear');
                        fstg(isnan(fstg)) = [f(isnan(fstg(:,:,:,1))); f(isnan(fstg(:,:,:,2))); f(isnan(fstg(:,:,:,3)))];
                end
            case 'backward'
                dimInd=obj.dimensions;
                switch dimInd
                    case 1
                        fstg(:, :, :, 1) = interpn(obj.kgridPadded.x, f, obj.kgridPadded.x - obj.kgridPadded.dx/2, '*linear');
                        fstg(isnan(fstg)) = f(isnan(fstg(:,:,:,1)));
                    case 2
                        fstg(:, :, :, 1) = interpn(obj.kgridPadded.x,obj.kgridPadded.y,  f, obj.kgridPadded.x - obj.kgridPadded.dx/2 , obj.kgridPadded.y, '*linear');
                        fstg(:, :, :, 2) = interpn(obj.kgridPadded.x,obj.kgridPadded.y,  f, obj.kgridPadded.x  , obj.kgridPadded.y - obj.kgridPadded.dy/2,  '*linear');
                        fstg(isnan(fstg)) = [f(isnan(fstg(:,:,:,1))); f(isnan(fstg(:,:,:,2)))];
                    case 3
                        fstg(:, :, :, 1) = interpn(obj.kgridPadded.x,obj.kgridPadded.y, obj.kgridPadded.z, f, obj.kgridPadded.x - obj.kgridPadded.dx/2 , obj.kgridPadded.y, obj.kgridPadded.z, '*linear');
                        fstg(:, :, :, 2) = interpn(obj.kgridPadded.x,obj.kgridPadded.y, obj.kgridPadded.z, f, obj.kgridPadded.x  , obj.kgridPadded.y - obj.kgridPadded.dy/2, obj.kgridPadded.z, '*linear');
                        fstg(:, :, :, 3) = interpn(obj.kgridPadded.x,obj.kgridPadded.y, obj.kgridPadded.z, f, obj.kgridPadded.x  , obj.kgridPadded.y , obj.kgridPadded.z - obj.kgridPadded.dz/2, '*linear');
                        fstg(isnan(fstg)) = [f(isnan(fstg(:,:,:,1))); f(isnan(fstg(:,:,:,2))); f(isnan(fstg(:,:,:,3)))];
                end
        end
end

end
