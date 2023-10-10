%% TestkWaveThermalMedium
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.TestInput
%
% Unit tests for the kWaveThermalMedium class using the TestMedium class.

classdef TestkWaveThermalMedium < kwave.tests.unit.TestInput

    properties
        inputClass = 'kWaveThermalMedium'
        inputProperties = {'density', 'specificHeat', 'thermalConductivity'}
        inputPropertiesPadded = {'densityPadded', 'specificHeatPadded', 'thermalConductivityPadded'}
        inputPropertiesScalar = {}
        inputPropertiesComplex = {}
    end

    methods(Test)
    end

end
