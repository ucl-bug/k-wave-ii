%% TestThermalMedium
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.AbstractTestGridInput
%
% Unit tests for the ThermalMedium class using the TestMedium class.

classdef TestThermalMedium < kwave.tests.unit.AbstractTestGridInput

    properties
        inputClass = 'ThermalMedium'
        inputProperties = {'density', 'specificHeat', 'thermalConductivity'}
        inputPropertiesPadded = {'densityPadded', 'specificHeatPadded', 'thermalConductivityPadded'}
        inputPropertiesScalar = {}
        inputPropertiesComplex = {}
    end

    methods(Test)
    end

end
