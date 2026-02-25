%% TestMedium
% *Package:* kwave.tests.unit
% Unit tests for the Materials-based Medium class (unpadded interface).

classdef TestMedium < matlab.unittest.TestCase
    properties
        kgrid
        materials
        medium
    end

    methods (TestMethodSetup)
        function createFixtures(test)
            import kwave.toolbox.*

            % Simple 2D grid with no padding
            test.kgrid = Grid([6, 4], 1e-3);

            % Fresh default Materials table (water=0, air=1)
            test.materials = Materials();

            % Medium object under test
            test.medium = Medium(test.kgrid, test.materials);
        end
    end

    % =====================================================================
    % Constructor behaviour
    % =====================================================================
    methods (Test)
        function testConstructorStoresHandles(test)
            test.verifyEqual(test.medium.kgrid,     test.kgrid);
            test.verifyEqual(test.medium.materials, test.materials);
        end
    end

    % =====================================================================
    % Virtual property: materialIndexGrid
    % =====================================================================
    methods (Test)
        function testVirtualPropertyExists(test)
            % Should appear as a property to the user
            p = properties(test.medium);
            test.verifyTrue(ismember("materialIndexGrid", string(p)));
        end

        function testAssignMaterialIndexGrid(test)
            % Assign unpadded virtual property
            ids = zeros(test.kgrid.gridSize, "uint8");
            ids(1,:) = 1;    % mixture of water (0) + air (1)

            test.medium.materialIndexGrid = ids;

            % Reading it back should give unpadded array
            out = test.medium.materialIndexGrid;
            test.verifyEqual(out, ids);
        end

        function testMaterialIndexGridSizeValidation(test)
            bad = zeros([7 4], "uint8");  % wrong size

            test.verifyError( ...
                @() setfield(test.medium,"materialIndexGrid",bad), ...
                "MATLAB:incorrectSize" ...
            );
        end
    end

    % =====================================================================
    % Derived material-property maps
    % =====================================================================
    methods (Test)
        function testDerivedMapsForSingleMaterial(test)
            % Assign homogeneous material: water (index 0)
            ids = zeros(test.kgrid.gridSize,'uint8');
            test.medium.materialIndexGrid = ids;

            % Values pulled from Materials.w ater struct
            w = test.materials.water;

            test.verifyEqual(test.medium.soundSpeed,          w.soundSpeed *  ones(test.kgrid.gridSize));
            test.verifyEqual(test.medium.density,             w.density    *  ones(test.kgrid.gridSize));
            test.verifyEqual(test.medium.absorptionPower,     w.absorptionPower);
        end

        function testDerivedMapsForMixedMaterials(test)
            ids = zeros(test.kgrid.gridSize,'uint8');
            ids(1:3,:) = 1;   % top half air, lower half water
            test.medium.materialIndexGrid = ids;

            w = test.materials.water;
            a = test.materials.air;

            ss = test.medium.soundSpeed;

            % Top rows are air
            test.verifyEqual(ss(1:3,:), a.soundSpeed * ones(3,4));

            % Bottom rows are water
            test.verifyEqual(ss(4:6,:), w.soundSpeed * ones(3,4));
        end

        function testMissingFieldProducesNaN(test)
            % Make custom material with missing fields
            [test.materials, idx] = test.materials.addMaterial("myTissue", struct( ...
                "soundSpeed", 1600, ...       % OK
                "density",     1050   ...     % OK
            ));

            ids = idx * ones(test.kgrid.gridSize,'uint8');
            test.medium.materialIndexGrid = ids;

            ap = test.medium.absorptionPowerMap;
            test.verifyTrue(all(isnan(ap(:))));
        end
    end

    % =====================================================================
    % subsref/subsasgn behaviour (virtual‑property plumbing)
    % =====================================================================
    methods (Test)
        function testSubsrefInsideMediumDoesNotError(test)
            % Should not throw "Unrecognized field 'materialIndexGrid'"
            ids = uint8(zeros(test.kgrid.gridSize));
            test.medium.materialIndexGrid = ids;

            % Access any derived property (exercise subsref → get.soundSpeed → mapProperty)
            ss = test.medium.soundSpeed;

            test.verifySize(ss, test.kgrid.gridSize);   % successful
        end
    end

    % =====================================================================
    % Immutability of materials handle
    % =====================================================================
    methods (Test)
        function testMaterialsHandleIsImmutable(test)
            p = findprop(test.medium, 'materials');
            test.verifyEqual(p.SetAccess, 'immutable');
        end
    end

    % =====================================================================
    % Display behaviour (no crash when invoked)
    % =====================================================================
    methods (Test)
        function testDisplayDoesNotError(test)
            ids = uint8(zeros(test.kgrid.gridSize));
            test.medium.materialIndexGrid = ids;

            % Exercise custom display which calls subsref/propertyGroups
            test.verifyWarningFree(@() disp(test.medium));
        end
    end
end