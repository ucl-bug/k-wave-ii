%% TestMaterials
% *Package:* kwave.tests.unit
%
% Unit tests for the kwave.toolbox.Materials class.

classdef TestMaterials < matlab.unittest.TestCase

    methods (Test)

        function testDefaultMaterialsExist(testCase)
            import kwave.toolbox.*

            mats = Materials();

            % Defaults: water + air should exist
            T = mats.listMaterialIndices();
            names = T.Name;
            testCase.verifyTrue(ismember("water", names));
            testCase.verifyTrue(ismember("air", names));

            % Listing must be sorted ascending by index (uint8)
            inds = double(T.Index);
            testCase.verifyEqual(inds, sort(inds));
            testCase.verifyClass(T.Index, 'uint8');
        end

        function testAutoAssignIndex(testCase)
            import kwave.toolbox.*

            mats = Materials();

            % Compute the next free (lowest) index in [0..255] from the live object
            T0   = mats.listMaterialIndices();
            used = double(T0.Index);
            free = setdiff(0:255, used, 'stable');
            testCase.assumeFalse(isempty(free), 'No free indices available to test auto-assignment.');

            s = struct('soundSpeed', 1500, 'density', 1000);
            [~, idx] = mats.addMaterial('tissue', s);   % uses public API

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
            [~, idx] = mats.addMaterial('mC', struct('index', 200, 'soundSpeed',1600,'density',1100));
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
                'Materials:DuplicateName');
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
                'Materials:DuplicateIndex');
        end

        function testMissingRequiredFieldsError(testCase)
            import kwave.toolbox.*

            mats = Materials();

            % Missing density
            s = struct('soundSpeed', 1500);
            testCase.verifyError( ...
                @() mats.addMaterial('bad', s), ...
                'Materials:MissingFields');
        end

        function testOptionalFieldsFillWithNaN(testCase)
            import kwave.toolbox.*

            mats = Materials();

            % Supply only required fields; optionals should be added and set to NaN
            s = struct('soundSpeed', 1540, 'density', 1000);
            mats.addMaterial('tissue', s);

            % Optional fields as per the class contract
            optionalFields = {'absorptionCoeff', ...
                'absorptionPower', ...
                'BonA', ...
                'specificHeat', ...
                'thermalConductivity'};

            for k = 1:numel(optionalFields)
                f = optionalFields{k};
                testCase.verifyTrue(isfield(mats.tissue, f), ...
                    sprintf('Missing optional field "%s".', f));

                v = mats.tissue.(f);
                testCase.verifyTrue(isnumeric(v), ...
                    sprintf('Optional field "%s" is not numeric.', f));
                testCase.verifyTrue(isnan(v), ...
                    sprintf('Optional field "%s" is not NaN.', f));
            end
        end

        function testIndexRangeError(testCase)
            import kwave.toolbox.*

            mats = Materials();

            % > 255 is out-of-range for uint8
            s = struct('index', 300, 'soundSpeed', 1500, 'density', 1000);
            testCase.verifyError( ...
                @() mats.addMaterial('badIdx', s), ...
                'Materials:IndexRange');
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
                'Materials:NoFreeIndex');
        end

        %% --- Validation tests for material property values ---

        function testSoundSpeedMustBePositive(testCase)
            import kwave.toolbox.*

            mats = Materials();

            badVals = {0, -1, -100, -eps, -Inf};
            for k = 1:numel(badVals)
                s = struct('soundSpeed', badVals{k}, 'density', 1000);
                testCase.verifyError( ...
                    @() mats.addMaterial(sprintf('badSS_%d', k), s), ...
                    'Materials:InvalidField');
            end
        end

        function testDensityMustBePositive(testCase)
            import kwave.toolbox.*

            mats = Materials();

            badVals = {0, -5, -Inf};
            for k = 1:numel(badVals)
                s = struct('soundSpeed', 1500, 'density', badVals{k});
                testCase.verifyError( ...
                    @() mats.addMaterial(sprintf('badDen_%d', k), s), ...
                    'Materials:InvalidField');
            end
        end

        function testSpecificHeatMustBePositiveOrNaN(testCase)
            import kwave.toolbox.*

            mats = Materials();

            % Valid (required fields only)
            mats.addMaterial('validSH', struct('soundSpeed', 1500, 'density', 1000));

            % Invalid: zero, negative
            badVals = {0, -1, -10};
            for k = 1:numel(badVals)
                s = struct('soundSpeed', 1500, 'density', 1000, ...
                    'specificHeat', badVals{k});
                testCase.verifyError( ...
                    @() mats.addMaterial(sprintf('badSH_%d', k), s), ...
                    'Materials:InvalidField');
            end
        end

        function testThermalConductivityMustBePositiveOrNaN(testCase)
            import kwave.toolbox.*

            mats = Materials();

            badVals = {0, -0.5, -10};
            for k = 1:numel(badVals)
                s = struct('soundSpeed', 1500, 'density', 1000, ...
                    'thermalConductivity', badVals{k});
                testCase.verifyError( ...
                    @() mats.addMaterial(sprintf('badTC_%d', k), s), ...
                    'Materials:InvalidField');
            end
        end

        function testAbsorptionCoeffMustBeNonnegativeOrNaN(testCase)
            import kwave.toolbox.*

            mats = Materials();

            badVals = {-0.1, -1, -20};
            for k = 1:numel(badVals)
                s = struct('soundSpeed',1500, 'density',1000, ...
                    'absorptionCoeff', badVals{k});
                testCase.verifyError( ...
                    @() mats.addMaterial(sprintf('badAC_%d', k), s), ...
                    'Materials:InvalidField');
            end
        end

        function testAbsorptionPowerMustBeNonnegativeOrNaN(testCase)
            import kwave.toolbox.*

            mats = Materials();

            badVals = {-0.1, -2, -10};
            for k = 1:numel(badVals)
                s = struct('soundSpeed',1500, 'density',1000, ...
                    'absorptionPower', badVals{k});
                testCase.verifyError( ...
                    @() mats.addMaterial(sprintf('badAP_%d', k), s), ...
                    'Materials:InvalidField');
            end
        end

        function testBonAMustBeNonnegativeOrNaN(testCase)
            import kwave.toolbox.*

            mats = Materials();

            badVals = {-0.001, -7, -Inf};
            for k = 1:numel(badVals)
                s = struct('soundSpeed',1500,'density',1000,'BonA',badVals{k});
                testCase.verifyError( ...
                    @() mats.addMaterial(sprintf('badBonA_%d',k),s), ...
                    'Materials:InvalidField');
            end
        end

        function testAllFieldsRejectComplexValues(testCase)
            import kwave.toolbox.*

            mats = Materials();

            bad = 1 + 2i;

            % Try each field individually as complex
            fields = {'soundSpeed','density','absorptionCoeff', ...
                'absorptionPower','BonA','specificHeat','thermalConductivity'};

            for k = 1:numel(fields)
                f = fields{k};
                s = struct('soundSpeed',1500,'density',1000); % base valid struct
                s.(f) = bad;  % make this field complex

                testCase.verifyError( ...
                    @() mats.addMaterial(sprintf('badComplex_%s', f), s), ...
                    'Materials:InvalidField');
            end
        end

        function testOptionalFieldsAllowNaN(testCase)
            import kwave.toolbox.*

            mats = Materials();

            s = struct('soundSpeed',1500,'density',1000, ...
                'specificHeat', NaN, ...
                'thermalConductivity', NaN, ...
                'absorptionCoeff', NaN, ...
                'absorptionPower', NaN, ...
                'BonA', NaN);

            % Should succeed (NaN allowed in optional fields)
            mats.addMaterial('withNaNs', s);

            T = mats.listMaterials();
            idx = find(T.Name=="withNaNs");
            testCase.verifyTrue(isnan(T.absorptionCoeff(idx)));
        end

    end
end
