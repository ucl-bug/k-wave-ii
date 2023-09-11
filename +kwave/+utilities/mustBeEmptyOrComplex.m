%% mustBeComplex
% *Package:* kwave.utilities
%
% Validate that an input is complex.
%
%% Syntax
%   mustBeComplex(a)
%
%% Description
% |mustBeComplex| throws an error if |a| is not complex.
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