%% TestAcousticMedium
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.AbstractTestGridInput
%
% Unit tests for the AcousticMedium class using the TestMedium class.
%
%% Description
% Verifies the Acoustic solver will not run with a medium not of the
% medium or acoustic medium type.

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

classdef TestAcousticMedium < kwave.tests.unit.AbstractTestGridInput

    properties
        inputClass = 'AcousticMedium'
        inputProperties = {'soundSpeed', 'density', 'absorptionCoeff', 'BonA'}
        inputPropertiesPadded = {'soundSpeedPadded', 'densityPadded', 'absorptionCoeffPadded', 'BonAPadded'}
        inputPropertiesScalar = {'soundSpeedReference', 'absorptionPower'}
        inputPropertiesComplex = {}
        inputPropertiesVectorField = {}
    end

    methods(Test)

        %Verify error when thermal medium used in Acoustic Solver
        function testMissingProperties(testCase)
            import kwave.toolbox.*
            kgrid = Grid([10, 10, 10], 1e-3);
            medium = ThermalMedium(kgrid);
            medium.thermalConductivity = 0.52;
            medium.specificHeat = 3540;
            medium.density = 1000;
            source = AcousticSource(kgrid);
            testCase.verifyError(@() AcousticSolver(kgrid, medium, source, []), 'AcousticSolver:InvalidMediumType');
        end
        
    end

end
