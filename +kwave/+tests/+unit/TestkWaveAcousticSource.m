%% TestkWaveAcousticSource
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.TestMedium
%
% Unit tests for the kWaveAcousticSource class using the TestMedium class.

classdef TestkWaveAcousticSource < kwave.tests.unit.TestInput

    properties
        inputClass = 'kWaveAcousticSource'
        inputProperties = {'initialPressure'}
        inputPropertiesPadded = {'initialPressurePadded'}
        inputPropertiesScalar = {}
    end

    methods(Test)
    end

end
