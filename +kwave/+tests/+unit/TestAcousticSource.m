%% TestAcousticSource
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.AbstractTestGridInput
%
% Unit tests for the AcousticSource class using the AbstractTestGridInput class.

classdef TestAcousticSource < kwave.tests.unit.AbstractTestGridInput

    properties
        inputClass = 'AcousticSource'
        inputProperties = {'initialPressure'}
        inputPropertiesPadded = {'initialPressurePadded'}
        inputPropertiesScalar = {}
        inputPropertiesComplex = {}
    end

    methods(Test)
        
        % Tests if things like
        % `source.initialPressure.method.something(:,1).other etc work
        function testSubrefs(testCase)
            % Initialize source object
            grid = kwave.toolbox.Grid([64,64,], [0.5,0.5]);
            source = kwave.toolbox.AcousticSource(grid);
            source.initialPressure = rand(source.gridSize);

            % Check slicing
            testCase.verifyEqual(size(source.initialPressure(1,:)), [1, 64])
        end

        % Testing if subassignments like `source.initialPressure(idx) =
        % val` work
        function testSubasgn(testCase)
            % Initialize source object
            kgrid = kwave.toolbox.Grid([64,64,], [0.5,0.5]);
            randValue = rand(kgrid.gridSize);

            source = kwave.toolbox.AcousticSource(kgrid);
            source.initialPressure = rand(source.gridSize);
            source.initialPressure(1:kgrid.Nx/4, :) = 2000;

            randValue(1:kgrid.Nx/4, :) = 2000;

            % Check assignment
            testCase.verifyEqual(source.initialPressure, randValue)
        end

    end

end
