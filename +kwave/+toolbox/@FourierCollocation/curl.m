%% curl
% *Class:* kwave.toolbox.FourierCollocation
% *Package:* kwave.toolbox
%
% Calculate the components of the curl of a three-dimensional vector field.
%
%% Syntax
%   df = curl(obj, f)
%   df = curl(obj, f, Staggering='forward')
%
%% Description
% Calculates the components of the curl of a vector field in 3D using a
% Fourier collocation spectral method. 
% 
% The vector components of the input and output fields are stacked in the
% 4th dimension. For example, the input must have dimensions (Nx, Ny, Nz,
% 3) and the output will be the same size. This is to allow codes to
% implement multi-dimensional support by always looping over the fourth
% dimension. 
%
% The curl operations are defined on the padded grid. Thus, the inputs to
% this function must also be defined on the padded grid. The output can be
% returned on a spatially staggered grid by setting the optional
% |Staggering| argument.   
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
% * |df| - (numeric) Components of divergence of f.

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


function f = curl(obj, f, options)
% Note: operations can be performed in-place, so we don't allocate a
% separate output variable.

arguments
    obj
    f(:,:,:,:)
    options.Staggering(1,:) char {mustBeMember(options.Staggering, {'none', 'forward', 'backward'})} = 'none'
end

% Check the input is a 3D vector field
if size(f,4) ~= 3
        kwave.toolbox.Logger.error('FourierCollocation:not3DVectorField', 'curl is only defined for three-dimensional vector fields.');        
end

% Calculate the gradients of each component of the field.
dfx = gradient(obj, f(:,:,:,1), Staggering = options.Staggering);
dfy = gradient(obj, f(:,:,:,2), Staggering = options.Staggering);
dfz = gradient(obj, f(:,:,:,3), Staggering = options.Staggering);

% Calculate the three curl components.
f(:,:,:,1) = dfz(:,:,:,2) - dfy(:,:,:,3);
f(:,:,:,2) = dfx(:,:,:,3) - dfz(:,:,:,1);
f(:,:,:,3) = dfy(:,:,:,1) - dfx(:,:,:,2);

end
