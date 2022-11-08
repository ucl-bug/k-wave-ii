%% TestCodeQuality
% *Package:* kwave.tests.unit
% *Superclasses:* matlab.unittest.TestCase
%
% Code quality tests for the k-wave II code base.
%
% For each file in +kwave/+toolbox this uses the built in `checkcode`
% function to make sure there are no code quality errors in the files.

classdef TestCodeQuality < matlab.unittest.TestCase

    methods
        function string_representation = problemToString(~, problem, mfile)

            % Convert a problem to a string. This is used to print the
            % problems.
            string_representation = sprintf(...
                "%s:%d:%d - Error: %s %s\n", ...
                mfile, ...
                problem.line, ...
                problem.column, ...
                problem.id, ...
                problem.message);
        end
    end

    methods(Test)

        function testCodeQuality(testCase)
            mfiles = dir(fullfile(mfilename('fullpath'), '..', '..', '..', '..', '+kwave', '**', '*.m'));
            % Check that at least one file is collected.
            testCase.assertGreaterThan(size(mfiles), 0);

            % Check each one with `checkcode`.
            for fileInd = 1:numel(mfiles)
                % Get the full path to the file.
                mfile = fullfile(mfiles(fileInd).folder, mfiles(fileInd).name);

                % Run `checkcode` on the file.
                disp("Checking " + mfile)
                [problems, ~] = checkcode(mfile, "-id");

                % Display any problems identified by checkcode before
                % failing the test.
                if ~isempty(problems)
                    disp("Linting Errors:")
                    for probInd = 1:numel(problems)
                        disp(testCase.problemToString(problems(probInd), mfile));
                    end
                end

                testCase.verifyEmpty(problems);
            end
        end
    end
end
