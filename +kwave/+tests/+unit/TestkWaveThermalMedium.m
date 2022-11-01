%% TestkWaveThermalMedium
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.TestMedium
%
% Unit tests for the kWaveThermalMedium class using the TestMedium class.

classdef TestkWaveThermalMedium < kwave.tests.unit.TestMedium

    properties
        mediumClass = 'kWaveThermalMedium'
        mediumProperties = {'density', 'specificHeat', 'thermalConductivity'}
        mediumPropertiesPadded = {'densityPadded', 'specificHeatPadded', 'thermalConductivityPadded'}
        mediumPropertiesScalar = {}
    end

    methods(Test)
    end

end
