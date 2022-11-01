%% TestkWaveAcousticMedium
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.TestMedium
%
% Unit tests for the kWaveAcousticMedium class using the TestMedium class.

classdef TestkWaveAcousticMedium < kwave.tests.unit.TestInput

    properties
        mediumClass = 'kWaveAcousticMedium'
        mediumProperties = {'soundSpeed', 'density', 'alphaCoeff', 'BonA'}
        mediumPropertiesPadded = {'soundSpeedPadded', 'densityPadded', 'alphaCoeffPadded', 'BonAPadded'}
        mediumPropertiesScalar = {'soundSpeedReference', 'alphaPower'}
    end

    methods(Test)
    end

end
