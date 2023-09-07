%% TestCodeQuality
% *Package:* kwave.tests.linting
% *Superclasses:* matlab.unittest.TestCase
%
% Code quality tests for the k-wave II code base.
%
%% Description
% The following tests are performed for all .m files in +kwave/+toolbox:
%
% # |codeIssues| is called to make sure there are no code quality
% errors in the files.
% # A dependency check is performed to make sure the files don't depend on
% any MATLAB toolboxes.

classdef TestCodeQuality < matlab.unittest.TestCase

    properties
        toolboxFileNames;
    end

    methods(TestClassSetup)
        function getFileNames(testCase)

            % Get all the m-files in the toolbox namespace.
            mfiles = dir(fullfile(mfilename('fullpath'), '..', '..', '..', '..', '+kwave/+toolbox', '**', '*.m'));

            % Check that at least one file is collected.
            testCase.assertGreaterThan(size(mfiles), 0);

            % Full pathnames to each file.
            testCase.toolboxFileNames = cellfun(@(x,y) fullfile(x,y), {mfiles.folder}, {mfiles.name}, 'UniformOutput', false);

        end
    end

    methods(Test)

        % Check for problems identified by codeIssues.
        function testCodeQuality(testCase)

            % Check for code issues.
            issues = codeIssues(testCase.toolboxFileNames);

            % Display any problems identified before failing the test.
            if ~isempty(issues.Issues)
                issues.Issues;
            end
            testCase.verifyEmpty(issues.Issues);

        end

        % Check for MATLAB toolbox dependencies.
        function checkDependencies(testCase)

            % Check for dependencies.
            [~, productList] = matlab.codetools.requiredFilesAndProducts(testCase.toolboxFileNames, 'toponly');

            % Display any required toolboxes before failing the test. The
            % product list will always contain 'MATLAB', so check for > 1.
            if numel(productList) > 1
                disp('The following MATLAB toolbox dependencies have been introduced and should be removed:');
                for depInd = 1:(numel(productList))
                    if ~strcmp(productList(depInd).Name, 'MATLAB')
                        disp(['- ' productList(depInd).Name]);
                    end
                end
            end
            testCase.verifyEqual(numel(productList), 1);

        end

    end
end
