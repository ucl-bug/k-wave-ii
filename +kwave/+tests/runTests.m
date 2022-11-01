%% runTests
% Run specified type of tests.
%
%% Syntax
%   kwave.tests.runTests()
%   kwave.tests.runTests(testType)
%
%% Description
% |runTests| uses the MATLAB class-based unit testing framework to set up a
% suite of tests, and then run these using a test runner. The test type is
% specified by the optional |testType| input, which determines which folder
% is used to search for the tests, and where the test artifacts are saved.
%
% All functions and classes should be accompanied by a test. Test files
% should be named 'Test' followed by the function or class name, e.g.,
% |TestMyClass|. Individual tests must derive from
% |matlab.unittest.TestCase|.
%
%% Input Arguments
% * |testType| - (kwave.tests.TestType) Test type. Default =
%   kwave.tests.TestType.unit.
%
%% See Also
% * |TestType|

function runTests(testType)

arguments
    testType kwave.tests.TestType = kwave.tests.TestType.unit;
end

% Check for MATLAB version 2022a = 9.12.
% See https://en.wikipedia.org/wiki/MATLAB for a list of version numbers.
if verLessThan('matlab', '9.12')
    error('MATLAB 2022a or later is required to use k-Wave-II.');
end

import matlab.unittest.TestRunner
import matlab.unittest.Verbosity
import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.XMLPlugin
import matlab.unittest.plugins.codecoverage.CoberturaFormat
import kwave.toolbox.*
import kwave.tests.*

% Setup testing suite for specified type of test.
testsFolder = fullfile(fileparts(which(mfilename)), testType.testsFolderName);
artifactFolder = fullfile(fileparts(which(mfilename)), testType.artifactsFolderName);
suite = testsuite(testsFolder, 'IncludeSubfolders', false);

% Generate clean artifact directory.
if exist(artifactFolder, 'dir')
    rmdir(artifactFolder, 's');
end
mkdir(artifactFolder);

% Setup and launch runner.
runner = TestRunner.withTextOutput('OutputDetail', Verbosity.Detailed);
runner.addPlugin(XMLPlugin.producingJUnitFormat(fullfile(artifactFolder, 'results.xml')));
runner.addPlugin(CodeCoveragePlugin.forFolder([testsFolder '/../../+toolbox'], ...
    'IncludingSubfolders', true, ...
    'Producing', CoberturaFormat(fullfile(artifactFolder, 'cobertura.xml'))));

results = runner.run(suite);
assertSuccess(results);

end
