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

function mustBeEqualSize(a, b)
    if ~isequal(size(a), size(b))
        eid = 'Size:notEqual';
        msg = 'Inputs must have equal size.';
        throwAsCaller(MException(eid,msg));
    end
end
