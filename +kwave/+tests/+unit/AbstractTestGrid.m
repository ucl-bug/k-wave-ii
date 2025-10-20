%% AbstractTestGrid
% *Package:* kwave.tests.unit
% *Superclasses:* matlab.unittest.TestCase
%
% Super class for tests requiring a Grid object of different sizes.
%
%% Description
% Abstract test class for tests that require a |kwave.toolbox.Grid| object
% with different sizes and dimensions. Each test method should define
% |testClass.actualSolution| and |testClass.referenceSolution|. Comparisons
% should be made using |testCase.verifyThat| as shown in the example below.
% |kwave.toolbox.Grid| objects are defined on both the unpadded (|kgrid|)
% and padded domains (|kgridPadded|). The test class also sets up a failure
% diagnostic that plots the differences in the actual and reference
% solution.
%
%% Examples
% Example of a derived test class that uses the parametrised Grid
% object. This automatically loops over different 1D, 2D, and 3D
% |kwave.toolbox.Grid| objects assigned to |kgrid|.
%
%    classdef TestMyClass < kwave.tests.unit.AbstractTestGrid
%        methods(Test, ParameterCombination="sequential")
%            function testSomething(testCase)
% 
%                import matlab.unittest.constraints.IsEqualTo
%                import kwave.toolbox.*
% 
%                % Assign actual and reference solutions.
%                testCase.actualSolution = testCase.kgrid.xVec;
%                testCase.referenceSolution = testCase.kgrid.yVec;
% 
%                % Compare with tolerance.
%                testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));
% 
%            end
%        end
%    end
%
%% See Also
% * |AbstractTestGridInput|

classdef(Abstract) AbstractTestGrid < matlab.unittest.TestCase

    properties
        kgrid kwave.toolbox.Grid
        kgridPadded kwave.toolbox.Grid
        actualSolution single
        referenceSolution single
        tol matlab.unittest.constraints.AbsoluteTolerance
    end

    properties(MethodSetupParameter)

        % Grid size and spacing to loop over. These test different possible
        % inputs for 1D, 2D and 3D domains with even and odd sizes, and
        % with and without padding.
        gridSize = {64, 64, 63, 65, [32, 48], [32, 48], [35, 45], [35, 45], [24, 28, 32], [24, 28, 32], [25, 27, 35], [25, 27, 35]};
        gridSpacing = num2cell(ones(1, 12) * 1e-3);
        gridPadding = {0, 8, 0, 9, [0, 0], [4, 6], [0, 0], [5, 9], [0, 0, 0], [6, 4, 4], [0, 0, 0], [1, 4, 5]};

    end

    methods(TestMethodSetup, ParameterCombination="sequential")

        % Create Grid object and single precision tolerance used by
        % tests. If a test fails, the difference in the fields is plotted.
        function createGrid(testCase, gridSize, gridSpacing, gridPadding)

            % Create grids.
            testCase.kgrid = kwave.toolbox.Grid(gridSize, gridSpacing, gridPadding);
            testCase.kgridPadded = kwave.toolbox.Grid(gridSize + 2.* gridPadding, gridSpacing);

            % Define tolerance for field comparisons.
            testCase.tol = matlab.unittest.constraints.AbsoluteTolerance(single(1e-6));

            % Add diagnostic for test failure.
            plotTitle = ['Grid Size: [' num2str(gridSize) '], Padding Size: [' num2str(gridPadding) ']'];
            testCase.onFailure(@()kwave.utilities.plotFieldsDiff(testCase.actualSolution, testCase.referenceSolution, plotTitle));

        end

    end

end
