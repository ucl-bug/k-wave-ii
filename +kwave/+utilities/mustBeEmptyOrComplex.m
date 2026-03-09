%% Must Be Empty Or Complex
% *Package:* kwave.utilities
%
% Validate that an input is an empty array or a complex array / scalar.
%
%% Syntax
%   mustBeEmptyOrComplex(a)
%
%% Description
% |mustBeEmptyOrComplex| throws an error if |a| is not empty or complex.
% This function does not return a value. 
%
%% Input Arguments
% * |a| - Input to validate.

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

function mustBeEmptyOrComplex(a)
    if ~isempty(a) && isreal(a)
        eid = 'Type:notComplex';
        msg = 'Value must be complex.';
        throwAsCaller(MException(eid,msg));
    end
end
