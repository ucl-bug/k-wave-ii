%% TestSplitFieldPML
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.TestGrid
%
% Unit tests for the SplitFieldPML class.
%
%% Description
% Simple test that creates a |SplitFieldPML| object and applies it to a
% vector field, and checks that the interior region doesn't change. All
% dimensions and grid staggering options are tested.

classdef TestSplitFieldPML < kwave.tests.unit.AbstractTestGrid

    % Add PML to class properties so we can pass it to each testCase.
    properties
        pml kwave.toolbox.SplitFieldPML
    end

    % Setup PML for each test.
    methods(TestMethodSetup, ParameterCombination="sequential")
        function createPML(testCase)           
            testCase.pml = kwave.toolbox.SplitFieldPML(testCase.kgrid);
            testCase.pml.setupQuarticPML(1, 1500);
        end
    end

    % Test methods.
    methods(Test, ParameterCombination="sequential")

        % Test getters and setters.
        function testGettersSetters(testCase)
            for dimInd = 1:testCase.kgrid.dimensions
                pmlProfile = zeros(testCase.kgridPadded.gridSize(dimInd), 1, 'single');
                switch dimInd
                    case 1
                        pmlProfile = reshape(pmlProfile, [], 1, 1);
                        testCase.pml.pmlX = pmlProfile;
                        testCase.verifyEqual(testCase.pml.pmlX, pmlProfile);
                        testCase.pml.pmlXStaggered = pmlProfile;
                        testCase.verifyEqual(testCase.pml.pmlXStaggered, pmlProfile);
                    case 2
                        pmlProfile = reshape(pmlProfile, 1, [], 1);
                        testCase.pml.pmlY = pmlProfile;
                        testCase.verifyEqual(testCase.pml.pmlY, pmlProfile);
                        testCase.pml.pmlYStaggered = pmlProfile;
                        testCase.verifyEqual(testCase.pml.pmlYStaggered, pmlProfile);
                    case 3
                        pmlProfile = reshape(pmlProfile, 1, 1, []);
                        testCase.pml.pmlZ = pmlProfile;
                        testCase.verifyEqual(testCase.pml.pmlZ, pmlProfile);
                        testCase.pml.pmlZStaggered = pmlProfile;
                        testCase.verifyEqual(testCase.pml.pmlZStaggered, pmlProfile);
                end
            end
        end

        % Test PML application on the regular grid.
        function testRegularPML(testCase)

            import matlab.unittest.constraints.IsEqualTo

            % Create test field.
            vectorField = rand([testCase.kgridPadded.gridSize, testCase.kgridPadded.dimensions]);

            % Apply PML.
            vectorFieldAtten = testCase.pml.applyPML(vectorField);

            % Make sure interior isn't changed.
            testCase.actualSolution = testCase.kgrid.returnWithoutGridPadding(vectorFieldAtten);
            testCase.referenceSolution = testCase.kgrid.returnWithoutGridPadding(vectorField);
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

        end

        % Test PML application on the staggered grid.
        function testStaggeredPML(testCase)

            import matlab.unittest.constraints.IsEqualTo

            % Create test field.
            vectorField = rand([testCase.kgridPadded.gridSize, testCase.kgridPadded.dimensions]);            

            % Apply PML.
            vectorFieldAtten = testCase.pml.applyPML(vectorField, Staggered=true);

            % Make sure interior isn't changed.
            testCase.actualSolution = testCase.kgrid.returnWithoutGridPadding(vectorFieldAtten);
            testCase.referenceSolution = testCase.kgrid.returnWithoutGridPadding(vectorField);
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

        end

    end
end
