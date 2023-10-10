%% getWavenumbers
% *Class:* kwave.toolbox.kWaveGrid
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
% the spectrum. Use |ifftshift| to transform this so the DC component is
% the first element.
%
%% Input Arguments
% * |numGridPoints| - (double) Number of grid points.
% * |gridSpacing| - (double) Grid point spacing [m].
%
%% Output Arguments
% * |kVec| - (double) Wavenumber vector.

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
