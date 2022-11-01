%% getWavenumbers
% *Class:* kwave.toolbox.kWaveGrid
% *Package:* kwave.toolbox
%
% Create vector of wavenumbers.
%
%% Syntax
%   kVec = getWavenumbers(gridPoints, gridSpacing)
%
%% Description
% Pads an input matrix using |expandMatrix| to account for the
% |gridPadding| of the associated |kWaveGrid| object.
%
%% Input Arguments
% * |gridPoints| - (double) Number of grid points.
% * |gridSpacing| - (double) Grid point spacing [m].

function kVec = getWavenumbers(gridPoints, gridSpacing)

arguments
    gridPoints(1,1) {mustBeInteger,mustBePositive}
    gridSpacing(1,1) {mustBeFinite,mustBeNonnegative}
end

% Define the discretisation of the spatial dimension such that
% there is always a DC component.
if gridPoints == 1

    % One grid point, so only DC component.
    kVec = 0;
    return

elseif rem(gridPoints, 2) == 0

    % Grid dimension has an even number of points.
    nx = ((-gridPoints/2:gridPoints/2-1)/gridPoints).';

else

    % Grid dimension has an odd number of points.
    nx = ((-(gridPoints-1)/2:(gridPoints-1)/2)/gridPoints).';

end

% Force middle value to be zero in case 1/Nx is a recurring
% number and the series doesn't give exactly zero.
nx(floor(gridPoints/2) + 1) = 0;

% Define the wavenumber vector components.
kVec = (2*pi/gridSpacing) .* nx;       
