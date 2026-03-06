%% TestMaterials
% *Package:* kwave.tests.unit
% *Superclasses:* matlab.unittest.TestCase
%
% Unit tests for the kwave.toolbox.Materials class.

classdef TestMaterials < matlab.unittest.TestCase

    properties
        materials
    end

    
    methods (TestMethodSetup)
        function createMaterials(testCase)
            testCase.materials = kwave.toolbox.Materials();
        end
    end


    methods (Test)

        function testMaterialName(testCase)

            % Try to name a material with a number
            s = struct('soundSpeed', 1540, 'density', 1000);
            name = 0; % shouldn't be a number
            testCase.verifyError( ...
                @() testCase.materials.addMaterial(name, s), ...
                'Materials:InvalidNameType');

        end

        function testDefaultMaterialsExist(testCase)

            % Defaults: water + air should exist
            T = testCase.materials.listMaterialIndices();
            testCase.assertNotEmpty(T.Name == "water", ...
                '"water" should be one of the default materials.');
            testCase.assertNotEmpty(T.Name == "air", ...
                '"air" should be one of the default materials.');

            % Listing must be sorted ascending by index
            testCase.verifyEqual(T.Index, sort(T.Index), ...
                'Material indices should always be sorted in ascending order.');
            testCase.verifyClass(T.Index, 'uint8');
            
        end

        function testAutoAssignIndex(testCase)

            % Compute the next free (lowest) index in [0..255] from the object
            T0   = testCase.materials.listMaterialIndices();
            used = T0.Index;
            free = setdiff(uint8(0:255), used, 'stable');
            testCase.assumeFalse(isempty(free), 'No free indices available to test auto-assignment.');

            s = struct('soundSpeed', 1500, 'density', 1000);
            idx = testCase.materials.addMaterial('tissue', s);

            % Returns a uint8 and equals the lowest free index we computed
            testCase.assertClass(idx, 'uint8');
            testCase.verifyEqual(idx, uint8(free(1)));

            % Check it's in the listing
            T = testCase.materials.listMaterialIndices();
            testCase.assertNotEmpty(T.Name == "tissue", ...
                '"tissue" material was not found after insertion.');

            % Listing must be sorted ascending by index
            testCase.verifyEqual(T.Index, sort(T.Index), ...
                'Material indices should always be sorted in ascending order.');

        end

        function testExplicitIndexAcceptedAndSorting(testCase)

            % Add with explicit indices (out of order to test sort)
            testCase.materials.addMaterial('mA', struct('index', 50,  'soundSpeed',1500,'density',1000));
            testCase.materials.addMaterial('mB', struct('index', 5,   'soundSpeed',1400,'density', 950));
            idx = testCase.materials.addMaterial('mC', struct('index', 200, 'soundSpeed',1600,'density',1100));
            testCase.assertEqual(idx, uint8(200));

            % Listing must be sorted ascending by index
            inds = testCase.materials.listMaterialIndices().Index;
            testCase.verifyEqual(inds, sort(inds), ...
                'Material indices should always be sorted in ascending order.');


        end

        function testDuplicateNameError(testCase)

            % add a material 
            s = struct('soundSpeed', 1500, 'density', 1000);
            testCase.materials.addMaterial('myMat', s);

            % Try to add another material with the same name
            testCase.verifyError( ...
                @() testCase.materials.addMaterial('myMat', s), ...
                'Materials:NameExists', ...
                'Adding a material with an existing name should trigger a NameExists error.');
        end

        function testDuplicateExplicitIndexError(testCase)

            % Pick an explicit free index safely
            used = testCase.materials.listMaterialIndices().Index;
            free = setdiff(uint8(0:255), used, 'stable');
            testCase.assumeGreaterThanOrEqual(numel(free), 1);
            I = free(1);

            % add a material with this index
            s1 = struct('index', I, 'soundSpeed', 1500, 'density', 1000);
            testCase.materials.addMaterial('m1', s1);

            % try to add another material with the same index
            s2 = struct('index', I, 'soundSpeed', 1400, 'density',  900);
            testCase.verifyError( ...
                @() testCase.materials.addMaterial('m2', s2), ...
                'Materials:IndexInUse');
        end

        function testMissingRequiredFieldsError(testCase)

            % Missing density
            s = struct('soundSpeed', 1500);
            testCase.verifyError( ...
                @() testCase.materials.addMaterial('bad', s), ...
                'Materials:MissingField');
        end

        function testExhaustionOfIndices(testCase)

            % Fill every remaining free index explicitly so that auto-assign has no space
            used = testCase.materials.listMaterialIndices().Index;
            free = setdiff(uint8(0:255), used, 'stable');

            for ii = 1:numel(free)
                name = sprintf('mat_%d', free(ii));
                s = struct('index', free(ii), 'soundSpeed', 1500, 'density', 1000);
                testCase.materials.addMaterial(name, s);
            end

            % Now all 256 indices should be used -> auto-assign should error
            testCase.verifyError( ...
                @() testCase.materials.addMaterial('extra', struct('soundSpeed',1500,'density',1000)), ...
                'Materials:NoIndicesLeft');
        end

        function testAddMaterials(testCase)

            % Index shouldn't be -1
            testCase.verifyError( ...
                @() testCase.materials.addMaterial('testTissue', struct('index', -1,'soundSpeed',1500,'density',1000)), ...
                'Materials:InvalidIndexField');

            % SoundSpeed shouldn't be positive
            testCase.verifyError( ...
                @() testCase.materials.addMaterial('testTissue', struct('soundSpeed',-1500,'density',1000)), ...
                'Materials:NotNonNegativeScalar');

            % name shouldn't be a number
            testCase.verifyError( ...
                @() testCase.materials.addMaterial(0, struct('soundSpeed',1500,'density',1000)), ...
                'Materials:InvalidNameType');

            % name shouldn't be in RESERVED_PROPS
            testCase.verifyError( ...
                @() testCase.materials.addMaterial('RESERVED_PROPS', struct('soundSpeed',1500,'density',1000)), ...
                'Materials:ReservedName');

            % Can't have an unknown field
            testCase.verifyError( ...
                @() testCase.materials.addMaterial('testTissue', struct('soundSpeed',1500,'density',1000,'unknownField',1500)), ...
                'Materials:UnknownField');

        end

        function testListMaterials(testCase)

            testCase.verifyWarningFree(@() testCase.materials.listMaterials());

        end

    end

end
