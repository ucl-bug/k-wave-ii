%% getQuarticPMLprofile
% *Package:* kwave.toolbox
% *Class:* kwave.toolbox.SplitFieldPML
%
% Return quartic PML profile.
%
%% Syntax
%   profile = kwave.toolbox.SplitFieldPML.getQuarticPMLProfile(numGridPoints, gridSpacing, timeStep, soundSpeed, options)
%
%% Description
% Static function that returns the 1D perfectly matched layer (PML) profile
% defined in <https://doi.org/10.1121/1.1421344> (Equation 27), where the
% absorption grows with the fourth power of the grid position within the
% PML. Note, the PML profile is transformed as described in the reference,
% where the profile is exponentiated and scaled by the time step size.
%
%% Input Arguments
% * |numGridPoints| - (integer) Total number of grid points in the profile
%   including the PML.
% * |gridSpacing| - (numeric) Grid point spacing [m].
% * |timeStep| - (numeric) Time step [s].
% * |soundSpeed| - (numeric) Sound speed in the PML [m/s].
%
%% Name-Value Arguments
% Specify optional pairs of arguments as |Name1=Value1,...,NameN=ValueN|,
% where |Name| is the argument name and |Value| is the corresponding value.
% Name-value arguments must appear after other arguments, but the order of
% the pairs does not matter.
%
% * |Axisymmetric| - (logical) If true, the PML profile isn't
%   applied to the axial side (beginning) of the PML. Default = false.
% * |Dimension| - (integer) Direction of the pml vector (1, 2, or 3).
% * |PMLAlpha| - (numeric) Absorption coefficient within the PML
%   [Nepers per grid point]. Default = 2.
% * |PMLSize| - (integer) Size of the PML on each side of the grid
%   [grid points]. Default = 10.
% * |Staggered| - (logical) If true, the PML profile is defined for
%   a grid staggered by half the grid point spacing. Default = false.
%
%% Output Arguments
% * |profile| - (numeric) PML profile.
%
%% See Also
% * |kwave.toolbox.setupQuarticPML|

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

function profile = getQuarticPMLProfile(numGridPoints, gridSpacing, timeStep, soundSpeed, options)

arguments
    numGridPoints(1,1) {mustBeInteger, mustBePositive}
    gridSpacing(1,1) {mustBePositive, mustBeFinite}
    timeStep(1,1) {mustBePositive, mustBeFinite}
    soundSpeed(1,1) {mustBePositive, mustBeFinite}
    options.Dimension(1,1) {mustBeInteger, mustBePositive, mustBeInRange(options.Dimension, 1, 3)} = 1
    options.PMLSize(1,1) {mustBeInteger, mustBeNonnegative} = 10
    options.PMLAlpha(1,1) {mustBeNonnegative, mustBeFinite} = 2
    options.Staggered(1,1) logical = false
    options.Axisymmetric(1,1) logical = false
end

% Define x-axis.
x = 1:options.PMLSize;

% Create absorption profile within the PML.
if options.Staggered
    leftPML  = options.PMLAlpha * (soundSpeed / gridSpacing) * ( ((x + 0.5) - options.PMLSize - 1) ./ (0 - options.PMLSize) ).^4; 
    rightPML = options.PMLAlpha * (soundSpeed / gridSpacing) * ( (x + 0.5) ./ options.PMLSize ).^4;   
else
    leftPML  = options.PMLAlpha * (soundSpeed / gridSpacing) * ( (x - options.PMLSize - 1) ./ (0 - options.PMLSize) ).^4;
    rightPML = options.PMLAlpha * (soundSpeed / gridSpacing) * ( x ./ options.PMLSize ).^4;
end

% Exponentiation.
leftPML  = exp(-leftPML  * timeStep / 2);
rightPML = exp(-rightPML * timeStep / 2);

% Add the components of the PML to the total profile, not adding the axial
% side of the radial PML if options.Axisymmetric = true.
profile = ones(1, numGridPoints);
if ~options.Axisymmetric
    profile(1:options.PMLSize) = leftPML;
end
profile(end - options.PMLSize + 1:end) = rightPML;

% Reshape the PML vector to be in the desired direction.
switch options.Dimension
    case 1
        profile = profile.';
    case 3
        profile = reshape(profile, [1, 1, numGridPoints]);
end
