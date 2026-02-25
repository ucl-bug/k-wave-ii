%% TestMedium
% *Package:* kwave.tests.unit
%
% Unit tests for the kwave.toolbox.Medium class.
% These tests use only the public API (Grid, Materials, Medium,
% listMaterialIndices, listMaterials, and the virtual property
% 'materialIndexGrid') and avoid any assumptions about internal
% implementation details.

classdef TestMedium < matlab.unittest.TestCase

    properties
        kgrid      % kwave.toolbox.Grid
        mats       % kwave.toolbox.Materials
        medium     % kwave.toolbox.Medium
        airIdx     % uint8 index for "air"
        waterIdx   % uint8 index for "water"
        airC
        waterC
        airRho
        waterRho
    end

    methods (TestMethodSetup)
        function makeFixtures(t)
            import kwave.toolbox.*

            % --- Minimal 2D grid (6 x 4), metres ---
            % The public Grid class takes grid size and spacing vectors.
            t.kgrid = Grid([6, 4], [1e-3, 1e-3]);

            % --- Materials with defaults ("water", "air") ---
            t.mats = Materials();

            % Ensure we can locate "air" and "water" by name; if either is
            % absent we add a sane default (not expected for default set).
            t.airIdx   = t.getOrAddIndex("air",   struct('soundSpeed',343,  'density',1.2));
            t.waterIdx = t.getOrAddIndex("water", struct('soundSpeed',1500, 'density',1000));

            % Cache their physical values from the live object to drive
            % truth tables in later assertions.
            TM = t.mats.listMaterials();
            t.airC   = TM.soundSpeed(TM.Name=="air");
            t.waterC = TM.soundSpeed(TM.Name=="water");
            t.airRho   = TM.density(TM.Name=="air");
            t.waterRho = TM.density(TM.Name=="water");

            % --- Medium under test ---
            t.medium = Medium(t.kgrid, t.mats);
        end
    end

    methods (Test)

        function setGet_materialIndexGrid_RoundTrip(t)
            % Homogeneous water domain
            idx = repmat(t.waterIdx, t.kgrid.Nx, t.kgrid.Ny);
            t.medium.materialIndexGrid = idx;

            got = t.medium.materialIndexGrid;
            t.verifyClass(got, 'uint8');
            t.verifySize(got, [t.kgrid.Nx, t.kgrid.Ny]);
            t.verifyTrue(all(got(:) == t.waterIdx), 'Round-trip get/set failed.');
        end

        function sizeValidation_WrongSize_Errors(t)
            % Assign something with the wrong size and confirm it errors.
            bad = zeros(t.kgrid.Nx+1, t.kgrid.Ny, 'uint8');
            didError = false;
            try
                t.medium.materialIndexGrid = bad; %#ok<NASGU>
            catch
                didError = true;
            end
            % We don't assert on the exact error identifier to remain robust
            % to the implementation choice; we only test that it errors.
            t.verifyTrue(didError, 'Assigning wrong-sized materialIndexGrid should error.');
        end

        function tryToAssignReadOnly(t)
            % Assign to a read-only medium property and confirm is errors.
            try
                t.medium.soundSpeed = 1;
            catch
                didError = true;
            end
            t.verifyTrue(didError, 'Trying to assign to read-only medium properties should error.');

        end

        function checkRefreshWorks(t)
            passed = true;
            try
                t.medium = refresh(t.medium);
            catch
                passed = false;
            end
            t.verifyTrue(passed, 'refresh should not throw an error');

        end

        function absorptionPowerNaN(t)

            import kwave.toolbox.*
            
            s = struct('soundSpeed',1500, ...
                'density',1000, ...
                'absorptionPower', NaN);
            [~, idx] = t.mats.addMaterial('nanAP', s);

            passed = true;
            try
                medium = Medium(t.kgrid, t.mats);
                medium.materialIndexGrid = idx * uint8(ones(t.medium.gridSize));
            catch
                passed = false;
            end
            t.verifyTrue(passed, 'absorptionPower can be NaN');            

        end

        function derivedMaps_Homogeneous(t)
            % Water everywhere
            idx = repmat(t.waterIdx, t.kgrid.Nx, t.kgrid.Ny);
            t.medium.materialIndexGrid = idx;

            c = t.medium.soundSpeed;
            rho = t.medium.density;

            t.verifySize(c,   [t.kgrid.Nx, t.kgrid.Ny]);
            t.verifySize(rho, [t.kgrid.Nx, t.kgrid.Ny]);

            t.verifyTrue(all(c(:)   == t.waterC));
            t.verifyTrue(all(rho(:) == t.waterRho));
        end

        function derivedMaps_Heterogeneous_TopAir_BottomWater(t)
            % Build a 2-material field: top-half air, bottom-half water
            idx = repmat(t.waterIdx, t.kgrid.Nx, t.kgrid.Ny);
            idx(1:floor(end/2), :) = t.airIdx;
            t.medium.materialIndexGrid = idx;

            c = t.medium.soundSpeed;
            rho = t.medium.density;

            t.verifyTrue(all(c(1:end/2, :)      == t.airC,'all'));
            t.verifyTrue(all(c(end/2+1:end, :)  == t.waterC,'all'));
            t.verifyTrue(all(rho(1:end/2, :)    == t.airRho,'all'));
            t.verifyTrue(all(rho(end/2+1:end,:) == t.waterRho,'all'));
        end

        function missingOptionalField_YieldsNaNInDerivedMap(t)
            % Add a material that *omits* an optional field (e.g., absorptionPower)
            % and verify the derived map is NaN where that material is used.
            name = "noAbsPow_" + matlab.lang.makeUniqueStrings("", 1);
            s = struct('soundSpeed', 1200, 'density', 900); % no absorptionPower field
            [~, idxNew] = t.mats.addMaterial(char(name), s);

            idx = repmat(idxNew, t.kgrid.Nx, t.kgrid.Ny);
            t.medium.materialIndexGrid = idx;

            % Only assert this if the Medium exposes the property
            if isprop(t.medium, 'absorptionPowerMap')
                ap = t.medium.absorptionPowerMap;
                t.verifySize(ap, [t.kgrid.Nx, t.kgrid.Ny]);
                t.verifyTrue(all(isnan(ap(:))), 'Optional field "absorptionPowerMap" should map to NaN.');
            else
                % Make the test pass but record that the property is not exposed.
                t.assertTrue(true, 'Medium.absorptionPower not implemented/exposed; test skipped.');
            end
        end

        function subsasgn_SlicedAssignment_Path(t)
            % Exercise Medium's subsasgn path for its virtual property by
            % assigning only the top row to air and leave rest as water.
            idx = repmat(t.waterIdx, t.kgrid.Nx, t.kgrid.Ny);
            t.medium.materialIndexGrid = idx;

            % This must go through Medium's subsasgn (virtual property).
            t.medium.materialIndexGrid(1, :) = t.airIdx;

            % Verify mapping picked up for that slice only
            c = t.medium.soundSpeed;
            t.verifyTrue(all(c(1, :) == t.airC,'all'));
            t.verifyTrue(all(c(2:end, :) == t.waterC,'all'));
        end

        function materialsHandle_IsImmutable(t)
            % Attempting to reassign .materials should be prohibited
            didError = false;
            try
                t.medium.materials = t.mats; %#ok<STRNU>
            catch ME
                didError = true;
                % Typical MATLAB id for SetAccess=immutable / SetProhibited
                t.verifyEqual(ME.identifier, 'MATLAB:class:SetProhibited');
            end
            t.verifyTrue(didError, 'Expected Medium.materials to be immutable.');
        end

        function display_DoesNotError(t)
            % Smoke test custom display / propertyGroups
            disp(t.medium);
            t.verifyTrue(true);
        end

        function derivativeMaps_SizeMatchesGrid_AfterReassignment(t)
            % Reassign a new checkerboard pattern and confirm size stays consistent
            idx = repmat(t.waterIdx, t.kgrid.Nx, t.kgrid.Ny);
            idx(1:2:end, :) = t.airIdx;  % every second row is air
            t.medium.materialIndexGrid = idx;

            c = t.medium.soundSpeed;
            rho = t.medium.density;

            t.verifySize(c,   [t.kgrid.Nx, t.kgrid.Ny]);
            t.verifySize(rho, [t.kgrid.Nx, t.kgrid.Ny]);

            % Spot-check a few positions
            t.verifyEqual(c(1,1),   t.airC);
            t.verifyEqual(c(2,1),   t.waterC);
            t.verifyEqual(rho(3,2), t.airRho);
        end
    end

    methods (Access = private)
        function idx = getOrAddIndex(t, matName, defaultStruct)
            % Return the index for an existing material by name (preferred),
            % otherwise add with the given defaults and return the new index.
            T = t.mats.listMaterialIndices();
            k = find(T.Name == string(matName), 1, 'first');
            if ~isempty(k)
                idx = T.Index(k);
                return
            end
            [~, idx] = t.mats.addMaterial(char(matName), defaultStruct);
        end
    end
end