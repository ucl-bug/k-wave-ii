%% TestAcousticMedium
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.AbstractTestGridInput
%
% Unit tests for the AcousticMedium class using the TestMedium class.

classdef TestAcousticMedium < kwave.tests.unit.AbstractTestGridInput

    properties
        inputClass = 'AcousticMedium'
        inputProperties = {'soundSpeed', 'density', 'absorptionCoeff', 'BonA'}
        inputPropertiesPadded = {'soundSpeedPadded', 'densityPadded', 'absorptionCoeffPadded', 'BonAPadded'}
        inputPropertiesScalar = {'soundSpeedReference', 'absorptionPower', 'absorptionType'}
        inputPropertiesComplex = {}
        inputPropertiesVectorField = {}
    end

    methods(Test)
    end

end
