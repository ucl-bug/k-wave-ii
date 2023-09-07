%% TestkWaveAcousticMedium
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.TestInput
%
% Unit tests for the kWaveAcousticMedium class using the TestMedium class.

classdef TestkWaveAcousticMedium < kwave.tests.unit.TestInput

    properties
        inputClass = 'kWaveAcousticMedium'
        inputProperties = {'soundSpeed', 'density', 'alphaCoeff', 'BonA'}
        inputPropertiesPadded = {'soundSpeedPadded', 'densityPadded', 'alphaCoeffPadded', 'BonAPadded'}
        inputPropertiesScalar = {'soundSpeedReference', 'alphaPower'}
    end

    methods(Test)
    end

end
