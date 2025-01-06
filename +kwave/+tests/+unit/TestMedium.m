%% TestAcousticMedium
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.AbstractTestGridInput
%
% Unit tests for the AcousticMedium class using the TestMedium class.

classdef TestMedium < kwave.tests.unit.AbstractTestGridInput

    properties
        inputClass = 'Medium'
        inputProperties = {'materialIDGrid'}
        inputPropertiesPadded = {'materialIDGridPadded'}
        inputPropertiesScalar = {'soundSpeedReference', 'diffusionReference'}
        inputPropertiesComplex = {}
        inputPropertiesVectorField = {'materialTable'}
    end

    methods(Test)
    end

end
