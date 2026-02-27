%% TestMaterials
% *Package:* kwave.tests.unit
%
% Unit tests for the kwave.toolbox.Materials class.

classdef TestMaterials < matlab.unittest.TestCase


    methods (Test)

        function testMaterialName(testCase)
            
            % Try to name a material with a number            
            import kwave.toolbox.*
            mats = Materials();
            s = struct('soundSpeed', 1540, 'density', 1000);
            name = 0; % shouldn't be a number
            testCase.verifyError( ...
                @() mats.addMaterial(name, s), ...
                'Materials:InvalidNameType');

        end

        function testDefaultMaterialsExist(testCase)

            % Defaults: water + air should exist
            import kwave.toolbox.*
            mats = Materials();
            T = mats.listMaterialIndices();
            names = T.Name;
            testCase.verifyTrue(ismember("water", names));
            testCase.verifyTrue(ismember("air", names));

            % Listing must be sorted ascending by index
            inds = double(T.Index);
            testCase.verifyEqual(inds, sort(inds));
            testCase.verifyClass(T.Index, 'uint8');
        end

        function testAutoAssignIndex(testCase)

            import kwave.toolbox.*
            mats = Materials();

            % Compute the next free (lowest) index in [0..255] from the object
            T0   = mats.listMaterialIndices();
            used = double(T0.Index);
            free = setdiff(0:255, used, 'stable');
            testCase.assumeFalse(isempty(free), 'No free indices available to test auto-assignment.');

            s = struct('soundSpeed', 1500, 'density', 1000);
            idx = mats.addMaterial('tissue', s); 

            % Returns a uint8 and equals the lowest free index we computed
            testCase.verifyClass(idx, 'uint8');
            testCase.verifyEqual(idx, uint8(free(1)));

            % Check it's in the listing and that the list remains sorted
            T = mats.listMaterialIndices();
            testCase.verifyTrue(any(T.Name == "tissue"));
            testCase.verifyEqual(double(T.Index), sort(double(T.Index)));
        end

        function testExplicitIndexAcceptedAndSorting(testCase)

            import kwave.toolbox.*
            mats = Materials();

            % Add with explicit indices (out of order to test sort)
            mats.addMaterial('mA', struct('index', 50,  'soundSpeed',1500,'density',1000));
            mats.addMaterial('mB', struct('index', 5,   'soundSpeed',1400,'density', 950));
            idx = mats.addMaterial('mC', struct('index', 200, 'soundSpeed',1600,'density',1100));
            testCase.verifyEqual(idx, uint8(200));

            % Listing must be sorted ascending by index
            inds = mats.listMaterialIndices().Index;
            testCase.verifyEqual(double(inds), sort(double(inds)));
        end

        function testDuplicateNameError(testCase)

            import kwave.toolbox.*
            mats = Materials();

            s = struct('soundSpeed', 1500, 'density', 1000);
            mats.addMaterial('myMat', s);

            testCase.verifyError( ...
                @() mats.addMaterial('myMat', s), ...
                'Materials:NameExists');
        end

        function testDuplicateExplicitIndexError(testCase)

            import kwave.toolbox.*
            mats = Materials();

            % Pick an explicit free index safely
            used = double(mats.listMaterialIndices().Index);
            free = setdiff(0:255, used, 'stable');
            testCase.assumeGreaterThanOrEqual(numel(free), 1);
            I = free(1);

            s1 = struct('index', I, 'soundSpeed', 1500, 'density', 1000);
            mats.addMaterial('m1', s1);

            s2 = struct('index', I, 'soundSpeed', 1400, 'density',  900);
            testCase.verifyError( ...
                @() mats.addMaterial('m2', s2), ...
                'Materials:IndexInUse');
        end

        function testMissingRequiredFieldsError(testCase)

            import kwave.toolbox.*
            mats = Materials();

            % Missing density
            s = struct('soundSpeed', 1500);
            testCase.verifyError( ...
                @() mats.addMaterial('bad', s), ...
                'Materials:MissingField');
        end

        function testExhaustionOfIndices(testCase)

            import kwave.toolbox.*
            mats = Materials();

            % Fill every remaining free index explicitly so that auto-assign has no space
            used = double(mats.listMaterialIndices().Index);
            free = setdiff(0:255, used, 'stable');

            for ii = 1:numel(free)
                name = sprintf('mat_%d', free(ii));
                s = struct('index', free(ii), 'soundSpeed', 1500, 'density', 1000);
                mats.addMaterial(name, s);
            end

            % Now all 256 indices should be used -> auto-assign should error
            testCase.verifyError( ...
                @() mats.addMaterial('extra', struct('soundSpeed',1500,'density',1000)), ...
                'Materials:NoIndicesLeft');
        end

        function testAddMaterials(testCase)

            import kwave.toolbox.*
            mats = Materials();

            % Index shouldn't be -1
            testCase.verifyError( ...
                @() mats.addMaterial('testTissue', struct('index', -1,'soundSpeed',1500,'density',1000)), ...
                'Materials:InvalidIndexField');

            % SoundSpeed shouldn't be positive
            testCase.verifyError( ...
                @() mats.addMaterial('testTissue', struct('soundSpeed',-1500,'density',1000)), ...
                'Materials:NotNonNegativeScalar');

            % name shouldn't be a number
            testCase.verifyError( ...
                @() mats.addMaterial(0, struct('soundSpeed',1500,'density',1000)), ...
                'Materials:InvalidNameType');

            % name shouldn't be in RESERVED_PROPS
            testCase.verifyError( ...
                @() mats.addMaterial('RESERVED_PROPS', struct('soundSpeed',1500,'density',1000)), ...
                'Materials:ReservedName');

            % Can't have an unknown field
            testCase.verifyError( ...
                @() mats.addMaterial('testTissue', struct('soundSpeed',1500,'density',1000,'unknownField',1500)), ...
                'Materials:UnknownField');

        end

        function testListMaterials(testCase)

            import kwave.toolbox.*
            mats = Materials();

            passed = true;

            % Check listMaterials runs
            try
                mats.listMaterials
            catch
                passed = false;
            end
            testCase.verifyTrue(passed)

        end

    end

end
