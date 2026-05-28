%% TestComplexSource
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.AbstractTestGridInput
%
% Unit tests for the ComplexSource class using the AbstractTestGridInput class.

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

classdef TestComplexSource < kwave.tests.unit.AbstractTestGridInput

    properties
        inputClass = 'ComplexSource'
        inputProperties = {'sourceField'}
        inputPropertiesComplex = {'sourceField', 'sourceFieldPadded'}
        inputPropertiesPadded = {'sourceFieldPadded'}
        inputPropertiesScalar = {}
        inputPropertiesVectorField = {}
        source
        testData
    end

    methods(TestMethodSetup)
        function setupTestData(testCase)
            testCase.source = kwave.toolbox.ComplexSource(testCase.kgrid);
            testCase.testData = single(rand(testCase.kgrid.gridSize) + 1i .* rand(testCase.kgrid.gridSize));
            testCase.source.sourceField = testCase.testData;
        end
    end

    methods(Test)

        function testSetAndGetSourceField(testCase)
            testCase.verifyEqual(testCase.source.sourceField, testCase.testData, 'AbsTol', 1e-6);
        end

        function testSourceFieldMagnitude(testCase)
            expectedMagnitude = abs(testCase.testData);
            testCase.verifyEqual(testCase.source.sourceFieldMagnitude, expectedMagnitude, 'AbsTol', 1e-6);
        end

        function testSourceFieldPhase(testCase)
            expectedPhase = angle(testCase.testData);
            testCase.verifyEqual(testCase.source.sourceFieldPhase, expectedPhase, 'AbsTol', 1e-6);
        end

    end

end
