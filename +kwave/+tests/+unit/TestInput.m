%% TestInput
% *Package:* kwave.tests.unit
% *Superclasses:* matlab.unittest.TestCase
%
% Superclass for medium unit tests.
%
%% Description
% Abstract test class for testing medium property classes derived from
% |kWaveInput|. Derived classes must define four abstract properties. The
% first defines the medium class name, and the others define cell arrays of
% the medium properties names for the class under test:
%
% * |mediumClass| - (char) Name of medium class.
% * |mediumProperties| - Cell array of property names defined on the
%   non-padded grid that can be either scalar values or spatially varying.
%   For example, |mediumProperties = {'soundSpeed', 'density'}.
% * |mediumPropertiesPadded| - Cell array of property names defined on the
%   padded grid that can be either scalar values or spatially varying. For
%   example, |mediumPropertiesPadded = {'soundSpeedPadded',
%   'densityPadded'}.
% * |mediumPropertiesScalar| - Cell array of property names for values that
%   must be scalar values. For 
%   example, |mediumPropertiesScalar = {'soundSpeedReference'}.
%
% Derived classes must also contain a test methods block (which can be
% empty) so that the tests run:
%
%    methods(Test)
%    end
%
% The test class then automatically tests homogeneous and heterogeneous
% property assignment, padded and non-padded size checks, and error states
% for grid sizes in 1D, 2D, and 3D.

classdef(Abstract) TestInput < matlab.unittest.TestCase

    properties(Abstract)
        mediumClass
        mediumProperties
        mediumPropertiesPadded
        mediumPropertiesScalar
    end

    properties
        kgrid kwave.toolbox.kWaveGrid
        medium
    end

    properties(MethodSetupParameter)

        % Grid size and spacing to loop over. These test different possible
        % inputs for 1D, 2D and 3D domains with and without padding.
        gridSize = {10, 10, [10, 12], [10, 12], [10, 12, 14], [10, 12, 14]};
        gridSpacing = {0.1, 0.1, [0.1, 0.2], [0.1, 0.2], [0.1, 0.2, 0.3], [0.1, 0.2, 0.3]};
        gridPadding = {0, 10, [0, 0], [10, 10], [0, 0, 0], [10, 10, 10]};

    end

    methods(TestMethodSetup, ParameterCombination="sequential")

        % Create grid and medium objects used by tests.
        function createGrid(testCase, gridSize, gridSpacing, gridPadding)
            testCase.kgrid = kwave.toolbox.kWaveGrid(gridSize, gridSpacing, gridPadding);
            testCase.medium = kwave.toolbox.(testCase.mediumClass)(testCase.kgrid);
        end

    end

    methods(Test)

        % Test not defining required properties throws an error.
        function testMissingProperties(testCase)
            testCase.verifyError(@() testCase.medium.checkRequiredProperties, 'kWaveInput:missingInput');
        end

        % Test homogeneous parameter assignment gives correct property
        % size for both padded and non-padded properties.
        function testHomogeneousProperties(testCase)

            % Combine properties and scalar properties.
            mediumPropertiesAll = [testCase.mediumProperties, testCase.mediumPropertiesScalar];

            % Assign medium properties and check size is 1.
            for ind = 1:length(mediumPropertiesAll)
                testCase.medium.(mediumPropertiesAll{ind}) = rand;
                testCase.verifyEqual(numel(testCase.medium.(mediumPropertiesAll{ind})), 1);
            end

            % Check size of padded properties is also 1.
            for ind = 1:length(testCase.mediumPropertiesPadded)
                testCase.verifyEqual(numel(testCase.medium.(testCase.mediumPropertiesPadded{ind})), 1);
            end

            % Test required properties are set.
            testCase.verifyWarningFree(@() testCase.medium.checkRequiredProperties);

        end

        % Test heterogeneous parameter assignment gives correct property
        % size for both padded and non-padded properties.
        function testHeterogenousProperties(testCase, gridSize, gridPadding)

            % Pad grid size to match output of size.
            paddedSize = gridSize + 2 * gridPadding;
            if numel(gridSize) == 1
                gridSize = [gridSize, 1];
                paddedSize = [paddedSize, 1];
            end

            % Assign medium properties and check size with and without
            % padding.
            for ind = 1:length(testCase.mediumProperties)
                testCase.medium.(testCase.mediumProperties{ind}) = rand(testCase.medium.gridSize);
                testCase.verifyEqual(size(testCase.medium.(testCase.mediumProperties{ind})), gridSize);
                testCase.verifyEqual(size(testCase.medium.(testCase.mediumPropertiesPadded{ind})), paddedSize);
            end

            % Test required properties are set.
            testCase.verifyWarningFree(@() testCase.medium.checkRequiredProperties);

        end

    end

end