%% TestThermalSolver
% *Package:* kwave.tests.unit
% *Superclasses:* matlab.unittest.TestCase
%
% Non-parameterised unit tests for the ThermalSolver class. Use this test
% class for tests that do not require automatically sweeping over the grid
% sizes defined in |AbstractTestGrid|.
%
%% Description
% Runs the following tests for the ThermalSolver:
%
% * Verifies that simulations using input parameters with a different grid
%   throw errors.

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

classdef TestThermalSolver < matlab.unittest.TestCase

    methods(Test)

        % Define medium and source inputs on a different grid, and test for
        % input errors.
        function testInputErrors(testCase)

            import kwave.toolbox.*

            kgrid = Grid([10, 10, 10], 1e-3);
            kgridIncorrect = Grid(10, 2e-3);

            % Medium using correct kgrid.
            medium = ThermalMedium(kgrid);
            medium.thermalConductivity = 0.52;
            medium.specificHeat = 3540;
            medium.density = 1000;

            % Medium using incorrect kgrid.
            mediumIncorrect = ThermalMedium(kgridIncorrect);
            mediumIncorrect.thermalConductivity = 0.52;
            mediumIncorrect.specificHeat = 3540;
            mediumIncorrect.density = 1000;

            % Source using correct kgrid.
            source = ThermalSource(kgrid);

            % Source using incorrect kgrid.
            sourceIncorrect = ThermalSource(kgridIncorrect);

            testCase.verifyWarningFree(@() ...
                ThermalSolver(kgrid, medium, source, []));

            testCase.verifyError(@() ...
                ThermalSolver(kgrid, mediumIncorrect, source, []), ...
                'Solver:gridMismatch');

            testCase.verifyError(@() ...
                ThermalSolver(kgrid, medium, sourceIncorrect, []), ...
                'Solver:gridMismatch');

        end

    end

end
