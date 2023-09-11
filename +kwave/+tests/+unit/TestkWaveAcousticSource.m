%% TestkWaveAcousticSource
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.TestInput
%
% Unit tests for the kWaveAcousticSource class using the TestInput class.

classdef TestkWaveAcousticSource < kwave.tests.unit.TestInput

    properties
        inputClass = 'kWaveAcousticSource'
        inputProperties = {'initialPressure'}
        inputPropertiesPadded = {'initialPressurePadded'}
        inputPropertiesScalar = {}
        inputPropertiesComplex = {}
    end

    methods(Test)
    end

end
