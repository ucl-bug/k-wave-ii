%% TestElectromagneticSource
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.AbstractTestGridInput
%
% Unit tests for the ElectromagneticSource class using the AbstractTestGridInput
% class.

classdef TestElectromagneticSource < kwave.tests.unit.AbstractTestGridInput

    properties
        inputClass = 'ElectromagneticSource'
        inputProperties = {'initialElectricField', 'initialMagneticField', ...
            'electricCurrentDensitySource', 'magneticCurrentDensitySource'} 
        inputPropertiesPadded = {'initialElectricFieldPadded', 'initialMagneticFieldPadded', ...
            'electricCurrentDensitySourcePadded', 'magneticCurrentDensitySourcePadded'}
        inputPropertiesScalar = {}
        inputPropertiesComplex = {}
    end

    methods(Test)
        
        % Tests nested sub-references work, for example:
        % source.initialElectricField.method.something(:, 1).other
        function testSubrefs(testCase)

            % Initialize source object.
            grid = kwave.toolbox.Grid([64,64], [0.5,0.5]);
            source = kwave.toolbox.ElectromagneticSource(grid);
            source.initialElectricField = rand(source.gridSize);
            source.initialMagneticField = rand(source.gridSize);

            % Check slicing.
            testCase.verifyEqual(size(source.initialElectricField(1,:)), [1, 64]);
            testCase.verifyEqual(size(source.initialMagneticField(1,:)), [1, 64]);

        end

        % Tests nested sub-assignments work, for example:
        % source.initialPressure(idx) = val
        function testSubasgn(testCase)

            % Initialize source object.
            kgrid = kwave.toolbox.Grid([64,64], [0.5,0.5]);
            randValue = rand(kgrid.gridSize);

            source = kwave.toolbox.ElectromagneticSource(kgrid);
            source.initialElectricField = randValue;
            source.initialElectricField(1:kgrid.Nx/4, :) = 2000;
            source.initialMagneticField = randValue;
            source.initialMagneticField(1:kgrid.Nx/4, :) = 2000;

            randValue(1:kgrid.Nx/4, :) = 2000;

            % Check assignment.
            testCase.verifyEqual(source.initialElectricField, randValue);
            testCase.verifyEqual(source.initialMagneticField, randValue);

        end

    end

end
