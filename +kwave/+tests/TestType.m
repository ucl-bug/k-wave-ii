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
% * *kwave.tests.TestType.linting:* Tests for code quality.
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
%
% The test folder must be the same the test type name.
%% See Also
% * |runTests|

% Copyright (C) 2024- The k-Wave Authors.
%
% This file is part of k-Wave-II (http://www.k-wave.org). k-Wave-II is free
% software: you can redistribute it and/or modify it under the terms of the
% GNU Lesser General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any
% later version.
%
% k-Wave-II is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
% License for more details.
%
% You should have received a copy of the GNU Lesser General Public License
% along with k-Wave-II. If not, see <http://www.gnu.org/licenses/>.

classdef TestType
    enumeration
        linting;
        unit;
    end
    methods
        function folder = testsFolderName(obj)
            folder = '+' + string(obj);
        end

        function folder = artifactsFolderName(obj)
            folder = string(obj) + '-tests-artifacts';
        end
    end
end
