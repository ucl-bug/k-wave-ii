%% mustBeAllOrNoneEmpty
% *Package:* kwave.utilities
%
% Validate that multiple inputs are either all empty, or none of them are
% empty. Can be used to check that sets of input arguments are all defined,
% or all not defined.
%
%% Syntax
%   mustBeAllOrNoneEmpty(a, b, ...);
%
%% Description
% |mustBeAllOrNoneEmpty| throws an error if two or more inputs are not
% either all empty, or all non-empty.
%
%% Input Arguments
% * |a|, |b|, ... - Inputs to validate.

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

function mustBeAllOrNoneEmpty(varargin)

    % Check if any input is empty.
    anyEmptyInput = any(cellfun(@isempty, varargin));
    
    % Check if all inputs are empty.
    allEmptyInputs = all(cellfun(@isempty, varargin));
    
    % Throw an error if some inputs are empty while others are non-empty.
    if anyEmptyInput && ~allEmptyInputs
        eid = 'Validators:mustBeAllOrNoneEmpty';
        msg = 'All inputs must be either empty or non-empty.';
        throwAsCaller(MException(eid,msg));
    end

end
