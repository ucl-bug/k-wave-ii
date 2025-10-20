%% TestAcousticSource
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.AbstractTestGridInput
%
% Unit tests for the AcousticSource class using the AbstractTestGridInput
% class.

classdef TestAcousticSource < kwave.tests.unit.AbstractTestGridInput

    properties
        inputClass = 'AcousticSource'
        inputProperties = {'initialPressure'}
        inputPropertiesPadded = {'initialPressurePadded'}
        inputPropertiesScalar = {}
        inputPropertiesComplex = {}
        inputPropertiesVectorField = {'initialVelocity','initialVelocityPadded'}
    end

    methods(Test)
        
        % Tests nested sub-references work, for example:
        % source.initialPressure.method.something(:, 1).other
        function testSubrefs(testCase)

            % Initialize source object.
            grid = kwave.toolbox.Grid([64,64,], [0.5,0.5]);
            source = kwave.toolbox.AcousticSource(grid);
            source.initialPressure = rand(source.gridSize);

            % Check slicing.
            testCase.verifyEqual(size(source.initialPressure(1,:)), [1, 64]);

        end

        % Tests nested sub-assignments work, for example:
        % source.initialPressure(idx) = val
        function testSubasgn(testCase)

            % Initialize source object.
            kgrid = kwave.toolbox.Grid([64,64,], [0.5,0.5]);
            randValue = rand(kgrid.gridSize);

            source = kwave.toolbox.AcousticSource(kgrid);
            source.initialPressure = randValue;
            source.initialPressure(1:kgrid.Nx/4, :) = 2000;

            randValue(1:kgrid.Nx/4, :) = 2000;

            % Check assignment
            testCase.verifyEqual(source.initialPressure, randValue);

        end

        % repeats tests for the Velocity
        function testVelSubrefs(testCase)

            % Initialize source object.
            grid = kwave.toolbox.Grid([64,64,], [0.5,0.5]);
            source = kwave.toolbox.AcousticSource(grid);
            source.initialVelocity = rand([source.gridSize,grid.dimensions]);

            % Check slicing.
            testCase.verifyEqual(size(source.initialVelocity(1,:,:,:)), [1, 64,1,2]);

        end

        % Tests nested sub-assignments work, for example:
        % source.initialPressure(idx) = val
        function testVelSubasgn(testCase)

            % Initialize source object.
            kgrid = kwave.toolbox.Grid([64,64,], [0.5,0.5]);
            randValue = rand([kgrid.gridSize,kgrid.dimensions]);

            source = kwave.toolbox.AcousticSource(kgrid);
            source.initialVelocity = randValue;
            source.initialVelocity(1:kgrid.Nx/4, :,:) = 2000;

            randValue(1:kgrid.Nx/4, :,:) = 2000;

            % Check assignment
            testCase.verifyEqual(source.initialVelocity, randValue);

        end
    end

end
