%% kappa Split Correction
% *Class:* kwave.toolbox.AcousticSolver
% *Package:* kwave.toolbox
%
% Calculate the temporal correction of a function in the time step
% variation
%
%% Syntax
%   fC = kappaSplitCorrection(obj, f)
%
%% Description
% Calculates the correction to the usual kspace corrected temporal
% derivative for using an varied time stepping by considering a first
% order interpolation.
%
% The vector components of the correction are stacked in the 4th dimension
% as with the gradient. For example, if calling gradient on a matrix of dimensions
% (10, 10), the output will be of size (10, 10, 1, 2). This is to allow
% codes to implement multi-dimensional support by always looping over the
% fourth dimension.
%
% The components are calculated using 1D FFTs, and kappa2 is applied in the
% Fourier domain. before inverting the Fourier Transform.
%
%
%% Input Arguments
% * |f| - (numeric) Scalar field that is to be corrected using.
%
%% Output Arguments
% * |fCorrected| - (numeric) Correction from f.

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


function fCorrected = kappaSplitCorrection(obj, f)

arguments
    obj
    f(:,:,:,:)
end

fCorrected = zeros([obj.kgridPadded.gridSize, obj.dimensions]);

for dim=1:obj.dimensions
    fCorrected(:, :, :,dim) = ifftn(obj.kappaSplit .* fftn(f(:,:,:,dim)), 'symmetric');
end

end
