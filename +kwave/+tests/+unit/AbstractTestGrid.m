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
% The test class also sets up a failure diagnostic that plots the
% differences in the actual and reference solution.
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
        actualSolution single
        referenceSolution single
        tol matlab.unittest.constraints.AbsoluteTolerance
    end

    properties(MethodSetupParameter)

        % Grid size and spacing to loop over. These test different possible
        % inputs for 1D, 2D and 3D domains with even and odd sizes.
        gridSize = {64, 65, [32, 48], [33, 49], [24, 28, 32], [25, 29, 33]};
        gridSpacing = {1e-3, 1e-3, 1e-3, 1e-3, 1e-3, 1e-3};

    end

    methods(TestMethodSetup, ParameterCombination="sequential")

        % Create Grid object and single precision tolerance used by
        % tests. If a test fails, the difference in the fields is plotted.
        function createGrid(testCase, gridSize, gridSpacing)

            % Create grid.
            testCase.kgrid = kwave.toolbox.Grid(gridSize, gridSpacing);

            % Define tolerance for field comparisons.
            testCase.tol = matlab.unittest.constraints.AbsoluteTolerance(single(1e-6));

            % Add diagnostic for test failure.
            testCase.onFailure(@()kwave.utilities.plotFieldsDiff(testCase.actualSolution, testCase.referenceSolution));

        end

    end

end
