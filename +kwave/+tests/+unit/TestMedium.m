%% TestMedium
% *Package:* kwave.tests.unit
% *Superclasses:* matlab.unittest.TestCase
%
% Unit tests for the kwave.toolbox.Medium class.

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

classdef TestMedium < kwave.tests.unit.AbstractTestGridInput

    properties
        kgrid
        materials
        medium
        airIdx
        waterIdx
        airC
        waterC
        airRho
        waterRho
    end

    methods (TestMethodSetup)
        function makeFixtures(testCase)

            % Small 2D grid
            testCase.kgrid = kwave.toolbox.Grid([6, 4], [1e-3, 1e-3]);

            % Materials with defaults ("water", "air")
            testCase.materials = kwave.toolbox.Materials();

            % Medium under test
            testCase.medium = kwave.toolbox.Medium(testCase.kgrid, testCase.materials);

            % Shorthands
            testCase.airIdx   = testCase.materials.air.index;
            testCase.waterIdx = testCase.materials.water.index;
            testCase.airC     = testCase.materials.air.soundSpeed;
            testCase.waterC   = testCase.materials.water.soundSpeed;
            testCase.airRho   = testCase.materials.air.density;
            testCase.waterRho = testCase.materials.water.density;

        end
    end

    methods (Test)

        function setGet_materialIndexGrid(testCase)

            % Homogeneous water domain
            idx = repmat(testCase.waterIdx, testCase.kgrid.Nx, testCase.kgrid.Ny);
            testCase.medium.materialIndexGrid = idx;

            got = testCase.medium.materialIndexGrid;
            testCase.assertClass(got, 'uint8', 'materialIndexGrid must always store uint8 indices.');
            testCase.assertSize(got, [testCase.kgrid.Nx, testCase.kgrid.Ny], ...
                'materialIndexGrid must preserve grid size.');
            testCase.verifyTrue(all(got(:) == testCase.waterIdx), ...
                'materialIndexGrid did not set/get the same index everywhere for a homogeneous water domain.');

        end

        function sizeValidation_WrongSize_Errors(testCase)

            % Assign something with the wrong size and confirm it errors.
            bad = zeros(testCase.kgrid.Nx+1, testCase.kgrid.Ny, 'uint8');
            didError = false;
            try
                testCase.medium.materialIndexGrid = bad;
            catch
                didError = true;
            end
            testCase.verifyTrue(didError, 'Assigning wrong-sized materialIndexGrid should error.');

        end

        function tryToAssignReadOnly(testCase)

            % Assign to a read-only medium property and confirm is errors.
            try
                testCase.medium.soundSpeed = 1;
            catch
                didError = true;
            end
            testCase.verifyTrue(didError, 'Trying to assign to read-only medium properties should error.');

        end

        function checkRefreshWorks(testCase)
            passed = true;
            try
                testCase.medium = refresh(testCase.medium);
            catch
                passed = false;
            end
            testCase.verifyTrue(passed, 'refresh should not throw an error');

        end

        function derivedMaps_Homogeneous(testCase)

            % Water, water everywhere
            idx = repmat(testCase.waterIdx, testCase.kgrid.Nx, testCase.kgrid.Ny);
            testCase.medium.materialIndexGrid = idx;

            c = testCase.medium.soundSpeed;
            rho = testCase.medium.density;

            testCase.verifySize(c,   [testCase.kgrid.Nx, testCase.kgrid.Ny]);
            testCase.verifySize(rho, [testCase.kgrid.Nx, testCase.kgrid.Ny]);

            testCase.verifyTrue(all(c(:)   == testCase.waterC));
            testCase.verifyTrue(all(rho(:) == testCase.waterRho));

        end

        function derivedMaps_Heterogeneous_TopAir_BottomWater(testCase)

            % Build a 2-material field: top-half air, bottom-half water
            idx = repmat(testCase.waterIdx, testCase.kgrid.Nx, testCase.kgrid.Ny);
            idx(1:floor(end/2), :) = testCase.airIdx;
            testCase.medium.materialIndexGrid = idx;

            c = testCase.medium.soundSpeed;
            rho = testCase.medium.density;

            testCase.verifyTrue(all(c(1:end/2, :)      == testCase.airC,'all'));
            testCase.verifyTrue(all(c(end/2+1:end, :)  == testCase.waterC,'all'));
            testCase.verifyTrue(all(rho(1:end/2, :)    == testCase.airRho,'all'));
            testCase.verifyTrue(all(rho(end/2+1:end,:) == testCase.waterRho,'all'));

        end

        function subsasgn_SlicedAssignment_Path(testCase)
            
            % Exercise Medium's subsasgn path for its virtual property by
            % assigning only the top row to air and leave rest as water.
            idx = repmat(testCase.waterIdx, testCase.kgrid.Nx, testCase.kgrid.Ny);
            testCase.medium.materialIndexGrid = idx;

            % This must go through Medium's subsasgn (virtual property).
            testCase.medium.materialIndexGrid(1, :) = testCase.airIdx;

            % Verify mapping picked up for that slice only
            c = testCase.medium.soundSpeed;
            testCase.verifyTrue(all(c(1, :) == testCase.airC,'all'));
            testCase.verifyTrue(all(c(2:end, :) == testCase.waterC,'all'));

        end

        function materialsHandle_IsImmutable(testCase)

            % Attempting to reassign .materials should be prohibited
            didError = false;
            try
                testCase.medium.materials = testCase.materials;
            catch ME
                didError = true;
                testCase.verifyEqual(ME.identifier, 'MATLAB:class:SetProhibited');
            end
            testCase.verifyTrue(didError, 'Expected Medium.materials to be immutable.');

        end

        function display_DoesNotError(testCase)

            % Test custom display / propertyGroups
            disp(testCase.medium);
            testCase.verifyTrue(true);

        end

        function derivativeMaps_SizeMatchesGrid_AfterReassignment(testCase)

            % Reassign a new checkerboard pattern and confirm size stays consistent
            idx = repmat(testCase.waterIdx, testCase.kgrid.Nx, testCase.kgrid.Ny);
            idx(1:2:end, :) = testCase.airIdx;  % every second row is air
            testCase.medium.materialIndexGrid = idx;

            c = testCase.medium.soundSpeed;
            rho = testCase.medium.density;

            testCase.verifySize(c,   [testCase.kgrid.Nx, testCase.kgrid.Ny]);
            testCase.verifySize(rho, [testCase.kgrid.Nx, testCase.kgrid.Ny]);

            % Spot-check a few positions
            testCase.verifyEqual(c(1,1),   testCase.airC);
            testCase.verifyEqual(c(2,1),   testCase.waterC);
            testCase.verifyEqual(rho(3,2), testCase.airRho);

        end

        function testGridIndexExpansion(testCase)

            % assigned properties should be gridSize
            testCase.medium.materialIndexGrid = uint8(1);
            no_dims = size(size(testCase.medium.soundSpeed),2);
            testCase.verifyEqual(size(testCase.medium.soundSpeed),testCase.medium.gridSize(1:no_dims))

        end

        function testAbsorptionPowerSetting(testCase)

            % No absorption sets map to NaNs
            idx = testCase.materials.addMaterial('testTissue',struct('soundSpeed',1500, 'density',1000));
            testCase.medium.materialIndexGrid = idx;
            testCase.verifyEqual(testCase.medium.absorptionPowerMap, single(NaN(testCase.kgrid.gridSize)))

            % Should have absorption of water
            testCase.medium.materialIndexGrid = uint8(0); % water
            v = testCase.medium.absorptionPower;
            testCase.verifyEqual(v, testCase.materials.water.absorptionPower)

        end

    end

end
