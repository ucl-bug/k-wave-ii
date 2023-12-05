%% takeTimeStep
% *Class:* kwave.toolbox.TimeDomainSolver
% *Package:* kwave.toolbox
%
% Iteratively update solution for given number of time steps.
%
%% Syntax
%   takeTimeStep(obj, Nt, dt)
%
%% Description
% Iteratively updates the PDE solution for the given number of time steps
% and time step size.
%
%% Input Arguments
% * |Nt| - (integer) Number of time steps.
% * |dt| - (numeric) Size of each time step. 

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

function takeTimeStep(obj, Nt, dt)

arguments
    obj
    Nt(1,1) {mustBeInteger, mustBePositive, mustBeFinite}
    dt(1,1) {mustBeNumeric, mustBePositive, mustBeFinite}
end

startTime = datetime('now');

kwave.toolbox.Logger.info(['Calling ' class(obj) '.takeTimeStep...']);
obj.kgrid.displayGridSize();
kwave.toolbox.Logger.info(['  dt: ' kwave.utilities.scaleSI(dt) 's, end time: ' kwave.utilities.scaleSI(dt * Nt) 's, time steps: ' num2str(Nt)]);

obj.executeTimeStep(Nt, dt);

elapsedTime = between(startTime, datetime('now'));
kwave.toolbox.Logger.info(['  takeTimeStep completed in ' kwave.utilities.formatDuration(elapsedTime)]);
