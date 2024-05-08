%% TestThermalSource
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.AbstractTestGridInput
%
% Unit tests for the ThermalSource class using the TestMedium class.

classdef TestThermalSource < kwave.tests.unit.AbstractTestGridInput

    properties
        inputClass = 'ThermalSource'
        inputProperties = {'initialTemperature'}
        inputPropertiesPadded = {'initialTemperaturePadded'}
        inputPropertiesScalar = {}
        inputPropertiesComplex = {}
        inputPropertiesVectorField = {}
    end

    methods(Test)
    end

end
