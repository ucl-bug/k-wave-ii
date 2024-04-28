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

    end

end
