%% TestAcousticSource
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.AbstractTestGridInput
%
% Unit tests for the AcousticSource class using the AbstractTestGridInput class.

classdef TestAcousticSource < kwave.tests.unit.AbstractTestGridInput

    properties
        inputClass = 'AcousticSource'
        inputProperties = {'initialPressure'}
        inputPropertiesPadded = {'initialPressurePadded'}
        inputPropertiesScalar = {}
        inputPropertiesComplex = {}
    end

    methods(Test)
    end

end
