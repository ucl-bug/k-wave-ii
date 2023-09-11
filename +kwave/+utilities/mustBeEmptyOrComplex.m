%% mustBeEmptyOrComplex
% *Package:* kwave.utilities
%
% Validate that an input is an empty array or
% a complex array / scalar.
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

function mustBeEmptyOrComplex(a)
    if ~isempty(a) && isreal(a)
        eid = 'Type:notComplex';
        msg = 'Value must be complex.';
        throwAsCaller(MException(eid,msg))
    end
end