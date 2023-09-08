%% runTests
% Run tests.
%
%% Syntax
%   kwave.tests.runTests()
%   kwave.tests.runTests(testType=type)
%
%% Description
% |runTests| uses the MATLAB class-based unit testing framework to set up a
% suite of tests, and then run these using a test runner. The test type is
% specified by the optional |testType| input, which determines which folder
% is used to search for the tests, and where the test artifacts are saved.
% If no input is given for |testType|, all test types defined by the
% |TestType| class are run.
%
% If the 'CI' environment variable is set to any value, a cobertura
% coverage XML file is saved. If this is not set a HTML code coverage page
% is generated that can be viewed in a web browser.
%
%% Input Arguments
% * |testType| - (kwave.tests.TestType) Test type.
%
%% See Also
% * |TestType|

function runTests(options)

arguments
    options.testType kwave.tests.TestType;
end

% Check for MATLAB version 2022b = 9.13.
% See https://en.wikipedia.org/wiki/MATLAB for a list of version numbers.
if verLessThan('matlab', '9.13')
    error('MATLAB 2022b or later is required to use k-Wave-II.');
end

import matlab.unittest.TestRunner
import matlab.unittest.Verbosity
import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.XMLPlugin
import matlab.unittest.plugins.codecoverage.CoberturaFormat
import matlab.unittest.plugins.codecoverage.CoverageReport
import kwave.toolbox.*
import kwave.tests.*

% If no input is given for testType, run all test types specified by the
% TestType class.
if isempty(fieldnames(options))
    TestTypes = enumeration('kwave.tests.TestType');
    for typeInd = 1:length(TestTypes)
        runTests(testType=TestTypes(typeInd))
    end
    return
end

% Setup testing suite for specified type of test.
testsFolder = fullfile(fileparts(which(mfilename)), options.testType.testsFolderName);
artifactFolder = fullfile(fileparts(which(mfilename)), options.testType.artifactsFolderName);
suite = testsuite(testsFolder, 'IncludeSubfolders', false);

% Generate clean artifact directory.
if exist(artifactFolder, 'dir')
    rmdir(artifactFolder, 's');
end
mkdir(artifactFolder);

% Setup test runner.
runner = TestRunner.withTextOutput('OutputDetail', Verbosity.Detailed);

% Configure code coverage collection.
if isenv('CI')

    % Generate a cobertura report that codecov understands when running
    % on continuous integration.
    coverage_file = fullfile(artifactFolder, 'cobertura.xml');
    report = CoberturaFormat(coverage_file);

else

    % Generate a human readable HTML file otherwise.
    report = CoverageReport(artifactFolder);

end
runner.addPlugin( ...
    CodeCoveragePlugin.forFolder( ...
        fullfile(testsFolder + '/../../+toolbox'), ...
        'IncludingSubfolders', true, ...
        'Producing', report));

% Run tests.
results = runner.run(suite);
assertSuccess(results);
