%% TestType
% *Package:* kwave.tests
%
% Enumeration class to specify test types.
%
%% Syntax
%   kwave.tests.TestType
%
%% Description
% Enumeration class to specify test types. Each test type has an associated
% test folder, and artifacts folder. The following test types are currently
% defined:
%
% * *kwave.tests.TestType.unit:* Tests for individual functions and class
%   methods. 
%
% In future, other tests types will also be added:
%
% * *kwave.tests.TestType.integration:* Real world tests that use multiple
%   functions or classes. 
% * *kwave.tests.TestType.regression:* Tests that outputs are stable over
%   time.
% * *kwave.tests.TestType.benchmarks:* Tests for performance.
%
%% See Also
% * |runTests|

classdef TestType
    enumeration
        unit;
    end
    methods
        function folder = testsFolderName(obj)
            switch obj
                case kwave.tests.TestType.unit
                    folder = '+unit';
            end
        end
        function folder = artifactsFolderName(obj)
            switch obj
                case kwave.tests.TestType.unit
                    folder = 'unit-tests-artifacts';
            end
        end        
    end
end
