%% TestkWaveComplexSource
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.TestInput
%
% Unit tests for the kWaveComplexSource class using the TestInput class.

classdef TestkWaveComplexSource < kwave.tests.unit.TestInput

  properties
      inputClass = 'kWaveComplexSource'
      inputProperties = {'sourceField'}
      inputPropertiesComplex = {'sourceField', 'sourceFieldPadded'}
      inputPropertiesPadded = {'sourceFieldPadded'}
      inputPropertiesScalar = {}
  end

  methods(Test)
      function testSetAndGetSourceField(testCase)
          kgrid = kwave.toolbox.kWaveGrid([32, 32], 1e-3);
          source = kwave.toolbox.kWaveComplexSource(kgrid);
          testData = rand(32, 32) + 1i * rand(32, 32);
          source.sourceField = testData;
          testCase.verifyEqual(source.sourceField, testData, 'AbsTol', 1e-6);
      end

      function testSourceFieldMagnitude(testCase)
          kgrid = kwave.toolbox.kWaveGrid([32, 32], 1e-3);
          source = kwave.toolbox.kWaveComplexSource(kgrid);
          testData = rand(32, 32) + 1i * rand(32, 32);
          source.sourceField = testData;
          expectedMagnitude = abs(testData);
          testCase.verifyEqual(source.sourceFieldMagnitude, expectedMagnitude, 'AbsTol', 1e-6);
      end

      function testSourceFieldPhase(testCase)
          kgrid = kwave.toolbox.kWaveGrid([32, 32], 1e-3);
          source = kwave.toolbox.kWaveComplexSource(kgrid);
          testData = rand(32, 32) + 1i * rand(32, 32);
          source.sourceField = testData;
          expectedPhase = angle(testData);
          testCase.verifyEqual(source.sourceFieldPhase, expectedPhase, 'AbsTol', 1e-6);
      end

  end

end
