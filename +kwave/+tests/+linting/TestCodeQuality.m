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
      % Convert a problem to a string.
      % This is used to print the problems.
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

      % Get all m-files in `mypackage`, recursively.
      % Keep the full path, so we can use it later.
      mfiles = dir(fullfile(mfilename('fullpath'), '..', '..', '..', '+toolbox', '**', '*.m'));
      % Check that at least one file is collected
      testCase.assertGreaterThan(size(mfiles), 0);

      % Check each one with `checkcode`.
      for i = 1:numel(mfiles)
        % Get the full path to the file.
        mfile = fullfile(mfiles(i).folder, mfiles(i).name);

        % Run `checkcode` on the file.
        disp("Checking " + mfile)
        [problems, ~] = checkcode(mfile, "-id");

        % Display problems if there are before failing the test
        if ~isempty(problems)
          % If there are problems, print them.
          disp("Linting Errors:")
          for j = 1:numel(problems)
            disp(testCase.problemToString(problems(j), mfile));
          end
        end

        testCase.verifyEmpty(problems);
      end
    end
  end
end
