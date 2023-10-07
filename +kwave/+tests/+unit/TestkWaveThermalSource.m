%% TestkWaveThermalSource
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.TestInput
%
% Unit tests for the kWaveThermalSource class using the TestMedium class.

classdef TestkWaveThermalSource < kwave.tests.unit.TestInput

    properties
        inputClass = 'kWaveThermalSource'
        inputProperties = {'initialTemperature'}
        inputPropertiesPadded = {'initialTemperaturePadded'}
        inputPropertiesScalar = {}
        inputPropertiesComplex = {}
    end

    methods(Test)
    end

end
