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
        inputPropertiesVectorField = {}
    end

    methods(Test)

        %Verify error when acousti medium used in Thermal Solver
        function testMissingProperties(testCase)
            import kwave.toolbox.*
            kgrid = Grid([10, 10, 10], 1e-3);
            medium = AcousticMedium(kgrid);
             medium.soundSpeed  = 1500;
             medium.density  = 1000;
             source = ThermalSource(kgrid);
            testCase.verifyError(@() ThermalSolver(kgrid, medium, source, []), 'ThermalSolver:InvalidMediumType');
        end

    end

end
