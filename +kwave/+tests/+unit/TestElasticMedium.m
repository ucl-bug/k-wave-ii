%% TestElasticMedium
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.AbstractTestGridInput
%
% Unit tests for the ElasticMedium class using the TestMedium class.

classdef TestElasticMedium < kwave.tests.unit.AbstractTestGridInput

    properties
        inputClass = 'ElasticMedium'
        inputProperties = {'density', 'soundSpeedCompression', 'soundSpeedShear', ...
                           'alphaCoeffCompression', 'alphaCoeffShear'}
        inputPropertiesPadded = {'densityPadded', 'soundSpeedCompressionPadded', 'soundSpeedShearPadded', ...
                           'alphaCoeffCompressionPadded', 'alphaCoeffShearPadded'}
        inputPropertiesScalar = {}
        inputPropertiesComplex = {}
        inputPropertiesVectorField = {}
    end

    methods(Test)
    end

end
