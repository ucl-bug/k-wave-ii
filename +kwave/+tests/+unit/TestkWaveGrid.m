%% TestkWaveGrid
% *Package:* kwave.tests.unit
% *Superclasses:* matlab.unittest.TestCase
%
% Unit tests for the kWaveGrid class.

classdef TestkWaveGrid < matlab.unittest.TestCase

    properties
        kgrid kwave.toolbox.kWaveGrid
    end

    properties(MethodSetupParameter)

        % Grid size and spacing to loop over. These test different possible
        % inputs for 1D, 2D and 3D domains with both odd and even grid
        % dimensions.
        gridSize = {10, 11, [10, 12], [11, 13], [10, 12, 14], [11, 13, 15], [10, 12], [10, 12, 14]};
        gridSpacing = {0.1, 0.1, 0.1, 0.1, 0.1, 0.1, [0.1, 0.2], [0.1, 0.2, 0.3]};

        % Padded versions for test comparison.
        gridSizePadded = {...
            [10, 1, 1], ...
            [11, 1, 1], ...
            [10, 12, 1], ...
            [11, 13, 1], ...
            [10, 12, 14], ...
            [11, 13, 15], ...
            [10, 12, 1], ...
            [10, 12, 14]};
        gridSpacingPadded = {...
            [0.1, 0, 0], ...
            [0.1, 0, 0], ...
            [0.1, 0.1, 0], ...
            [0.1, 0.1, 0], ...
            [0.1, 0.1, 0.1], ...
            [0.1, 0.1, 0.1], ...
            [0.1, 0.2, 0], ...
            [0.1, 0.2, 0.3]};

        % Largest prime factors for grid size.
        primeFactors = {...
            [5, 1, 1], ...
            [11, 1, 1], ...
            [5, 3, 1], ...
            [11, 13, 1], ...
            [5, 3, 7], ...
            [11, 13, 5], ...
            [5, 3, 1], ...
            [5, 3, 7]};

    end

    methods(TestMethodSetup, ParameterCombination="sequential")

        % Create kWaveGrid object used by tests.
        function createSource(testCase, gridSize, gridSpacing, gridSizePadded, gridSpacingPadded, primeFactors) %#ok<INUSD> 
            import kwave.toolbox.*;
            testCase.kgrid = kWaveGrid(gridSize, gridSpacing);
        end

    end

    % Parameterized tests.
    methods(Test, ParameterCombination="sequential")
        
        % Test grid size properties are correct. 
        function testGridSize(testCase, gridSizePadded, gridSpacingPadded)

            % Check grid size and spacing.
            testCase.verifyEqual(testCase.kgrid.gridSize, gridSizePadded);
            testCase.verifyEqual(testCase.kgrid.gridSpacing, gridSpacingPadded);
            testCase.verifyEqual(testCase.kgrid.totalGridPoints, prod(gridSizePadded));

            % Check individual components of grid size and spacing.
            testCase.verifyEqual(testCase.kgrid.Nx, gridSizePadded(1));
            testCase.verifyEqual(testCase.kgrid.Ny, gridSizePadded(2));
            testCase.verifyEqual(testCase.kgrid.Nz, gridSizePadded(3));
            testCase.verifyEqual(testCase.kgrid.dx, gridSpacingPadded(1));
            testCase.verifyEqual(testCase.kgrid.dy, gridSpacingPadded(2));
            testCase.verifyEqual(testCase.kgrid.dz, gridSpacingPadded(3));

            % Check physical grid size.
            testCase.verifyEqual(testCase.kgrid.xSize, gridSizePadded(1) * gridSpacingPadded(1));
            testCase.verifyEqual(testCase.kgrid.ySize, gridSizePadded(2) * gridSpacingPadded(2));
            testCase.verifyEqual(testCase.kgrid.zSize, gridSizePadded(3) * gridSpacingPadded(3));

        end

        % Test grid vectors are correct.
        function testGridVectors(testCase, gridSizePadded, gridSpacingPadded)

            % Build vectors, and offset to place 0 in the middle.
            xVec = (1:gridSizePadded(1)).' * gridSpacingPadded(1);
            yVec = (1:gridSizePadded(2)).' * gridSpacingPadded(2);
            zVec = (1:gridSizePadded(3)).' * gridSpacingPadded(3);
            xVec = xVec - xVec(ceil((end + 1)/2));
            yVec = yVec - yVec(ceil((end + 1)/2));
            zVec = zVec - zVec(ceil((end + 1)/2));

            % Verify against values computed by kWaveGrid.
            testCase.verifyEqual(testCase.kgrid.xVec, xVec, RelTol=1e-15);
            testCase.verifyEqual(testCase.kgrid.yVec, yVec, RelTol=1e-15);
            testCase.verifyEqual(testCase.kgrid.zVec, zVec, RelTol=1e-15);

            % Check against matrix versions.
            testCase.verifyEqual(testCase.kgrid.x(:, 1, 1), reshape(xVec, [], 1, 1), RelTol=1e-15);
            testCase.verifyEqual(testCase.kgrid.y(1, :, 1), reshape(yVec, 1, [], 1), RelTol=1e-15);
            testCase.verifyEqual(testCase.kgrid.z(1, 1, :), reshape(zVec, 1, 1, []), RelTol=1e-15);

        end

        % Test largest prime factors are correct.
        function testPrimeFactors(testCase, primeFactors)
            testCase.verifyEqual(testCase.kgrid.highestPrimeFactors, primeFactors);
        end

        % Test wavenumbers are correct.
        function testWavenumbers(testCase, gridSizePadded, gridSpacingPadded)

            % Compute maximum wavenumbers from grid size and spacing.
            if rem(gridSizePadded(1), 2)
                kxMax = pi / gridSpacingPadded(1) - pi / (gridSpacingPadded(1) * gridSizePadded(1));
            else
                kxMax = pi / gridSpacingPadded(1);
            end
            if gridSpacingPadded(2) == 0
                kyMax = 0;
            else
                if rem(gridSizePadded(2), 2)
                    kyMax = pi / gridSpacingPadded(2) - pi / (gridSpacingPadded(2) * gridSizePadded(2));
                else
                    kyMax = pi / gridSpacingPadded(2);
                end
            end
            if gridSpacingPadded(3) == 0
                kzMax = 0;
            else
                if rem(gridSizePadded(3), 2)
                    kzMax = pi / gridSpacingPadded(3) - pi / (gridSpacingPadded(3) * gridSizePadded(3));
                else
                    kzMax = pi / gridSpacingPadded(3);
                end
            end

            % Compute overall maximum wavenumber.
            kMaxVec = [kxMax, kyMax, kzMax];
            kMaxVec(kMaxVec == 0) = [];
            kMax = min(kMaxVec);

            % Verify maximum against values computed by kWaveGrid.
            testCase.verifyEqual(testCase.kgrid.kxMax, kxMax, RelTol=1e-15);
            testCase.verifyEqual(testCase.kgrid.kyMax, kyMax, RelTol=1e-15);
            testCase.verifyEqual(testCase.kgrid.kzMax, kzMax, RelTol=1e-15);
            testCase.verifyEqual(testCase.kgrid.kMax, kMax, RelTol=1e-15);

            % Verify first component of wavevector is maximum.
            testCase.verifyEqual(testCase.kgrid.kxVec(1), -kxMax, RelTol=1e-15);
            testCase.verifyEqual(testCase.kgrid.kyVec(1), -kyMax, RelTol=1e-15);
            testCase.verifyEqual(testCase.kgrid.kzVec(1), -kzMax, RelTol=1e-15);

            % Verify wavevector has DC in the centre.
            testCase.verifyEqual(testCase.kgrid.kxVec(ceil((gridSizePadded(1) + 1)/2)), 0);
            testCase.verifyEqual(testCase.kgrid.kyVec(ceil((gridSizePadded(2) + 1)/2)), 0);
            testCase.verifyEqual(testCase.kgrid.kzVec(ceil((gridSizePadded(3) + 1)/2)), 0);

            % Verify repeated wavevectors.
            testCase.verifyEqual(testCase.kgrid.kx(:, 1, 1), reshape(testCase.kgrid.kxVec, [], 1, 1), RelTol=1e-15);
            testCase.verifyEqual(testCase.kgrid.ky(1, :, 1), reshape(testCase.kgrid.kyVec, 1, [], 1), RelTol=1e-15);
            testCase.verifyEqual(testCase.kgrid.kz(1, 1, :), reshape(testCase.kgrid.kzVec, 1, 1, []), RelTol=1e-15);

            % Test scalar wavenumber has DC in the centre.
            centerPos = ceil((gridSizePadded + 1)/2);
            testCase.verifyEqual(testCase.kgrid.k(centerPos(1), centerPos(2), centerPos(3)), 0);

            % Test scalar wavenumber has correct corner value.
            cornerVal = norm(kMaxVec);
            testCase.verifyEqual(testCase.kgrid.k(1, 1, 1), cornerVal, RelTol=1e-15);

        end

        % Test size validation.
        function testValidateSize(testCase)
            import kwave.toolbox.*;
            matrix = rand(testCase.kgrid.gridSize);
            matrixPadded = rand(testCase.kgrid.gridSize + 2*testCase.kgrid.gridPadding);
            testCase.verifyWarningFree(@() testCase.kgrid.validateSize(matrix));
            testCase.verifyWarningFree(@() testCase.kgrid.validateSize(matrix, FunctionName='myFunction', VariableName='myVariable'));
            testCase.verifyWarningFree(@() testCase.kgrid.validateSize(matrixPadded, IncludePadding=true));
        end

    end

    % Single tests.
    methods(Test)

        % Test that a mismatch between the length of the grid size and grid
        % spacing inputs throws an error.
        function testIncorrectGridSpacing(testCase)
            import kwave.toolbox.*;
            sz = [10, 10];
            spacing = [1, 1, 1];
            testCase.verifyError(@() kWaveGrid(sz, spacing), 'kWaveGrid:incorrectInputSize');
        end

        % Test that a mismatch between the length of the grid size and grid
        % padding inputs throws an error.
        function testIncorrectGridPadding(testCase)
            import kwave.toolbox.*;
            sz = [10, 10];
            spacing = [1, 1];
            padding = [1, 1, 1];
            testCase.verifyError(@() kWaveGrid(sz, spacing, padding), 'kWaveGrid:incorrectInputSize');
        end

        % Test assigning grid padding.
        function testAssignGridPadding(testCase)
            import kwave.toolbox.*;
            sz = [10, 10];
            spacing = [1, 1];
            padding = [1, 1];
            testCase.verifyWarningFree(@() kWaveGrid(sz, spacing, padding));
        end

        % Test size check for vector fields.
        function testValidateSizeForVectors(testCase)
            a = rand([testCase.kgrid.gridSize, testCase.kgrid.dimensions]);
            testCase.verifyWarningFree(@() testCase.kgrid.validateSize(a, VectorField=true));
        end

    end

end
