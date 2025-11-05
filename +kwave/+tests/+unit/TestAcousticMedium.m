%% TestAcousticMedium
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.AbstractTestGridInput
%
% Unit tests for the AcousticMedium class using the TestMedium class.
%
%% Description
% Verifies the Acoustic solver will not run with a medium not of the
% medium or acoustic medium type.

classdef TestAcousticMedium < kwave.tests.unit.AbstractTestGridInput

    properties
        inputClass = 'AcousticMedium'
        inputProperties = {'soundSpeed', 'density', 'absorptionCoeff', 'BonA'}
        inputPropertiesPadded = {'soundSpeedPadded', 'densityPadded', 'absorptionCoeffPadded', 'BonAPadded'}
        inputPropertiesScalar = {'soundSpeedReference', 'absorptionPower'}
        inputPropertiesComplex = {}
        inputPropertiesVectorField = {}
    end

    methods(Test)

        %Verify error when thermal medium used in Acoustic Solver
        function testMissingProperties(testCase)
            import kwave.toolbox.*
            kgrid = Grid([10, 10, 10], 1e-3);
            medium = ThermalMedium(kgrid);
            medium.thermalConductivity = 0.52;
            medium.specificHeat = 3540;
            medium.density = 1000;
            source = AcousticSource(kgrid);
            testCase.verifyError(@() AcousticSolver(kgrid, medium, source, []), 'AcousticSolver:InvalidMediumType');
        end
    end


end
