%% TestElectromagneticMedium
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.AbstractTestGridInput
%
% Unit tests for the ElectromagneticMedium class using the TestMedium class.

classdef TestElectromagneticMedium < kwave.tests.unit.AbstractTestGridInput

    properties
        inputClass = 'ElectromagneticMedium'
        inputProperties = {'permittivity', 'permeability', 'conductivity'}
        inputPropertiesPadded = {'permittivityPadded', 'permeabilityPadded', 'conductivityPadded'}
        inputPropertiesScalar = {}
        inputPropertiesComplex = {}
    end

    methods(Test)
    end

end
