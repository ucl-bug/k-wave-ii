%% TestExpandMatrix
% *Package:* kwave.tests.unit
% *Superclasses:* matlab.unittest.TestCase
%
% Unit tests for the expandMatrix function.

classdef TestExpandMatrix < matlab.unittest.TestCase

    properties(TestParameter)
        gridSize           = {[2, 1, 1],          [2, 1, 1],          [1, 2, 1],          [1, 2, 1],          [2, 3, 1],          [2, 3, 1],          [2, 3, 1],          [2, 3, 4],          [2, 3, 4],          [2, 3, 4]};
        expansionSize      = {2,                  [2, 3],             2,                  [2, 3],             2,                  [2, 3],             [2, 3, 4, 5],       2,                  [2, 3, 4],          [2, 3, 4, 5, 6, 7]};
        contractionIndices = {[3, 4, 1, 1, 1, 1], [3, 4, 1, 1, 1, 1], [1, 1, 3, 4, 1, 1], [1, 1, 3, 4, 1, 1], [3, 4, 3, 5, 1, 1], [3, 4, 4, 6, 1, 1], [3, 4, 5, 7, 1, 1], [3, 4, 3, 5, 3, 6], [3, 4, 4, 6, 5, 8], [3, 4, 5, 7, 7, 10]};
        expectedSize       = {[6, 1],             [7, 1],             [1, 6],             [1, 7],             [6, 7],             [6, 9],             [7, 12],            [6, 7, 8],          [6, 9, 12],         [7, 12, 17]};
        expectedSum        = {9,                  11,                 9,                  11,                 147,                189,                314,                4200,               8100,               18946};
        expectedZeros      = {4,                  5,                  4,                  5,                  36,                 48,                 78,                 312,                624,                1404};
    end

    % Parameterized tests.
    methods(Test, ParameterCombination="sequential")

        % Expand using edge values. 
        function testOutputSize(testCase, gridSize, expansionSize, expectedSize, expectedSum, contractionIndices)
         
            import kwave.toolbox.*;

            % Create matrix with integers and expand using edge values.
            matrix = zeros(gridSize);
            matrix(1:end) = 1:numel(matrix);
            expandedMatrix = expandMatrix(matrix, expansionSize);

            % Check expanded grid size.
            testCase.verifyEqual(expectedSize, size(expandedMatrix));

            % Check expanded values via sum.
            testCase.verifyEqual(expectedSum, sum(expandedMatrix(:)));

            % Check internal matrix is recovered in correct position
            contractedMatrix = expandedMatrix(...
                contractionIndices(1):contractionIndices(2), ...
                contractionIndices(3):contractionIndices(4), ...
                contractionIndices(5):contractionIndices(6));
            testCase.verifyEqual(matrix, contractedMatrix);

        end

        % Expand using specified value. 
        function testExpansionValue(testCase, gridSize, expansionSize, expectedZeros, contractionIndices)
         
            import kwave.toolbox.*;

            % Create matrix with integers and expand using zeros.
            matrix = zeros(gridSize);
            matrix(1:end) = 1:numel(matrix);
            expandedMatrix = expandMatrix(matrix, expansionSize, 0);

            % Check number of zeros.
            testCase.verifyEqual(expectedZeros, sum(expandedMatrix(:) == 0));

            % Check internal matrix is recovered in correct position
            contractedMatrix = expandedMatrix(...
                contractionIndices(1):contractionIndices(2), ...
                contractionIndices(3):contractionIndices(4), ...
                contractionIndices(5):contractionIndices(6));
            testCase.verifyEqual(matrix, contractedMatrix);

        end

        % Test expansion of logical matrices.
        function testLogicalMatrix(testCase, gridSize, expansionSize, expectedZeros)
            import kwave.toolbox.*;
            
            matrix = true(gridSize);
            expandedMatrix = expandMatrix(matrix, expansionSize, false);

            % Check data type
            testCase.verifyEqual('logical', class(matrix));

            % Check number of falses.
            testCase.verifyEqual(expectedZeros, sum(expandedMatrix(:) == false));

        end

    end

    % Single tests.
    methods(Test)

        % Test that giving the wrong length for expansionSize throws error.
        function testIncorrectExpansionSize(testCase)
            import kwave.toolbox.*;
            testCase.verifyError(@() expandMatrix(rand(2, 1), [1 2 3]), 'expandMatrix:incorrectInputSize');
            testCase.verifyError(@() expandMatrix(rand(2, 2), [1 2 3]), 'expandMatrix:incorrectInputSize');
            testCase.verifyError(@() expandMatrix(rand(2, 2, 2), [1 2 3 4]), 'expandMatrix:incorrectInputSize');
        end

        % Test giving a matrix with too many dimensions throws error.
        function testHigherDimensionalMatrix(testCase)
            import kwave.toolbox.*;
            testCase.verifyError(@() expandMatrix(rand(2, 2, 2, 2), 1), 'expandMatrix:incorrectInputSize');
        end

    end

end
