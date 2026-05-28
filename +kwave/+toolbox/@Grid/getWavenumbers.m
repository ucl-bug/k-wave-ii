%% Get Wavenumbers
% *Class:* kwave.toolbox.Grid
% *Package:* kwave.toolbox
%
% Create vector of wavenumbers.
%
%% Syntax
%   kVec = getWavenumbers(numGridPoints, gridSpacing)
%
%% Description
% Creates the vector of wavenumbers (spatial frequencies) for use with the
% MATLAB fft functions. Internally, MATLAB uses FFTW, so the frequency bins
% match those used by FFTW. The DC component is returned in the centre of
% the spectrum. Use |<https://uk.mathworks.com/help/matlab/ref/ifftshift.html ifftshift>| to transform this
% so the DC component is the first element.
%
%% Input Arguments
% * |numGridPoints| - (double) Number of grid points.
% * |gridSpacing| - (double) Grid point spacing [m].
%
%% Output Arguments
% * |kVec| - (double) Wavenumber vector.

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

function kVec = getWavenumbers(numGridPoints, gridSpacing)

arguments
    numGridPoints(1,1) double {mustBeInteger,mustBePositive}
    gridSpacing(1,1) double {mustBeFinite,mustBeNonnegative}
end

% Define the discretisation of the spatial dimension such that
% there is always a DC component.
if numGridPoints == 1

    % One grid point, so only DC component.
    kVec = 0;
    return

elseif rem(numGridPoints, 2) == 0

    % Grid dimension has an even number of points.
    nx = ((-numGridPoints/2:numGridPoints/2-1)/numGridPoints).';

else

    % Grid dimension has an odd number of points.
    nx = ((-(numGridPoints-1)/2:(numGridPoints-1)/2)/numGridPoints).';

end

% Force middle value to be zero in case 1/Nx is a recurring
% number and the series doesn't give exactly zero.
nx(floor(numGridPoints/2) + 1) = 0;

% Define the wavenumber vector components.
kVec = (2*pi/gridSpacing) .* nx;
