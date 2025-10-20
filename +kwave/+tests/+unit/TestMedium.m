%% TestMedium
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.AbstractTestGridInput
%
% Unit tests for the Medium class using the TestMedium class.

classdef TestMedium < kwave.tests.unit.AbstractTestGridInput

    properties
        inputClass = 'Medium'
        inputProperties = {'materialIDGrid'}
        inputPropertiesPadded = {'materialIDGridPadded'}
        inputPropertiesScalar = {'soundSpeedReference', 'diffusionReference'}
        inputPropertiesComplex = {}
        inputPropertiesVectorField = {'materialTable'}
    end

    %Unpadded methods call the padded methods
    methods(Test, ParameterCombination="sequential")
        
        function callVariablesTest(testCase)

            import kwave.toolbox.*

            mediumConstant = Medium(testCase.kgrid);
            mediumVaried = Medium(testCase.kgrid);
            mediumConstant.materialIDGrid=1;
            mediumVaried.materialIDGrid= ones(testCase.kgrid.gridSize);
            mediumVaried.materialIDGrid(1)=2;
            mediumVaried.BonA;
            mediumVaried.density;
            mediumVaried.soundSpeed;
            mediumVaried.specificHeat;
            mediumVaried.thermalConductivity;
            mediumVaried.absorptionCoeff;
            mediumVaried.absorptionPower;
            mediumConstant.BonA;
            mediumConstant.density;
            mediumConstant.soundSpeed;
            mediumConstant.specificHeat;
            mediumConstant.thermalConductivity;
            mediumConstant.absorptionCoeff;
            mediumConstant.absorptionPower;
        end

    end

end
