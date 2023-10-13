%% TestComplexSource
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.AbstractTestGridInput
%
% Unit tests for the ComplexSource class using the AbstractTestGridInput class.

classdef TestComplexSource < kwave.tests.unit.AbstractTestGridInput

    properties
        inputClass = 'ComplexSource'
        inputProperties = {'sourceField'}
        inputPropertiesComplex = {'sourceField', 'sourceFieldPadded'}
        inputPropertiesPadded = {'sourceFieldPadded'}
        inputPropertiesScalar = {}
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
