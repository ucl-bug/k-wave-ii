%% Must Be Equal Size
% *Package:* kwave.utilities
%
% Validate that two inputs are the same size.
%
%% Syntax
%   mustBeEqualSize(a, b);
%
%% Description
% |mustBeEqualSize| throws an error if two inputs are not the same size.
% This function does not return a value. Implementation is based on MATLAB
% example code.
%
%% Input Arguments
% * |a|, |b| - Inputs to validate.

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

function mustBeEqualSize(a, b)
    if ~isequal(size(a), size(b))
        eid = 'Size:notEqual';
        msg = 'Inputs must have equal size.';
        throwAsCaller(MException(eid,msg));
    end
end
