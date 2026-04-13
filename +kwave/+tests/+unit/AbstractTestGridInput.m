%% AbstractTestGridInput
% *Package:* kwave.tests.unit
% *Superclasses:* matlab.unittest.TestCase
%
% Superclass for GridInput unit tests.
%
%% Description
% Abstract test class for testing property classes derived from
% |GridInput|. Derived classes must define six abstract properties. The  
% first defines the medium class name, and the others define cell arrays of
% the medium properties names for the class under test:
%
% * |inputClass| - (char) Name of input class.
% * |inputProperties| - Cell array of property names defined on the
%   non-padded grid that can be either scalar values or spatially varying.
%   For example, |inputProperties = {'soundSpeed', 'density'}|.
% * |inputPropertiesComplex| - Cell array of property names defined on the
%   padded grid that must be complex valued. For example,
%   |inputPropertiesComplex = {'sourceField'}|. Properties declared as
%   complex must also be defined in one of the other input arrays, e.g.,
%   |inputPropertiesPadded|.
% * |inputPropertiesPadded| - Cell array of property names defined on the
%   padded grid that can be either scalar values or spatially varying. For
%   example, |inputPropertiesPadded = {'soundSpeedPadded',
%   'densityPadded'}|.
% * |inputPropertiesScalar| - Cell array of property names for values that
%   must be scalar values. For example, |inputPropertiesScalar =
%   {'soundSpeedReference'}|.
% * |inputPropertiesVectorField| - Cell array of property names for values that
%   must be vector fields. For example, |inputPropertiesScalar =
%   {'initialVelocity'}|.
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

% Copyright (C) 2024- The k-Wave Authors.
%
% This file is part of k-Wave-II (http://www.k-wave.org). k-Wave-II is free
% software: you can redistribute it and/or modify it under the terms of the
% GNU Lesser General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any
% later version.
% 
% k-Wave-II is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
% License for more details.
% 
% You should have received a copy of the GNU Lesser General Public License
% along with k-Wave-II. If not, see <http://www.gnu.org/licenses/>.

classdef(Abstract) AbstractTestGridInput < matlab.unittest.TestCase

    properties(Abstract)
        inputClass
        inputProperties
        inputPropertiesPadded
        inputPropertiesScalar
        inputPropertiesComplex
        inputPropertiesVectorField
    end

    properties
        kgrid kwave.toolbox.Grid
        input
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
            testCase.kgrid = kwave.toolbox.Grid(gridSize, gridSpacing, gridPadding);
            testCase.input = kwave.toolbox.(testCase.inputClass)(testCase.kgrid);
        end

    end

    methods

        % Checks if a property must be complex, to e.g. help setting test 
        % values.
        function isComplex = mustBeComplex(testCase, propertyName)
            isComplex = ismember(propertyName, testCase.inputPropertiesComplex);
        end

        % Checks if a property is a vector field.
        function vectorField = isVectorField(testCase, propertyName)
            vectorField = ismember(propertyName, testCase.inputPropertiesVectorField);
        end

        % Returns a random initialization value for a property.
        function val = randomPropertyValue(testCase, propertyName, gridSize)
            arguments
                testCase
                propertyName (1,:) char
                gridSize = 1
            end

            isComplex = testCase.mustBeComplex(propertyName);
            if gridSize == 1
                val = rand + 1i .* rand .* isComplex; 
            else
                if testCase.isVectorField(propertyName)
                    gridSize(4) = testCase.kgrid.dimensions;
                end
                val = rand(gridSize) + 1i .* isComplex;
            end
         end
    
    end

    methods(Test)

        % Test not defining required properties throws an error.
        function testMissingProperties(testCase)
            if ~isempty(testCase.input.requiredProperties)
                testCase.verifyError(@() testCase.input.checkRequiredProperties, 'GridInput:missingInput');
            end
        end

        % Test homogeneous parameter assignment gives correct property
        % size for both padded and non-padded properties.
        function testHomogeneousProperties(testCase)

            % Combine properties and scalar properties.
            mediumPropertiesAll = [testCase.inputProperties, testCase.inputPropertiesScalar];

            % Assign medium properties and check size is 1.
            for ind = 1:length(mediumPropertiesAll)
                testCase.input.(mediumPropertiesAll{ind}) = testCase.randomPropertyValue(mediumPropertiesAll{ind});
                testCase.verifyEqual(numel(testCase.input.(mediumPropertiesAll{ind})), 1);
            end

            % Check size of padded properties is also 1.
            for ind = 1:length(testCase.inputPropertiesPadded)
                testCase.verifyEqual(numel(testCase.input.(testCase.inputPropertiesPadded{ind})), 1);
            end

            % Test required properties are set.
            testCase.verifyWarningFree(@() testCase.input.checkRequiredProperties);

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
            for ind = 1:length(testCase.inputProperties)
                val = testCase.randomPropertyValue(testCase.inputProperties{ind}, testCase.input.gridSize);
                testCase.input.(testCase.inputProperties{ind}) = val;

                % Account for vector fields which have vector components
                % stored in fourth dimension.
                expectedGridSize = gridSize;
                expectedPaddedSize = paddedSize;
                if (testCase.kgrid.dimensions > 1)
                    if testCase.isVectorField(testCase.inputProperties{ind})
                        expectedGridSize(4) = testCase.kgrid.dimensions;
                        expectedGridSize(expectedGridSize == 0) = 1;
                    end
                    if testCase.isVectorField(testCase.inputPropertiesPadded{ind})
                        expectedPaddedSize(4) = testCase.kgrid.dimensions;
                        expectedPaddedSize(expectedPaddedSize == 0) = 1;
                    end
                end

                testCase.verifyEqual(size(testCase.input.(testCase.inputProperties{ind})), expectedGridSize);
                testCase.verifyEqual(size(testCase.input.(testCase.inputPropertiesPadded{ind})), expectedPaddedSize);
            end

            % Test required properties are set.
            testCase.verifyWarningFree(@() testCase.input.checkRequiredProperties);

        end

        % Test the command line display when typing the object name.
        function testCustomDisplay(testCase)

            % Assign medium properties.
            for ind = 1:length(testCase.inputProperties)
                val = testCase.randomPropertyValue(testCase.inputProperties{ind}, testCase.input.gridSize);
                testCase.input.(testCase.inputProperties{ind}) = val;
            end

            % Check command line output works.
            testCase.input

        end

    end

end