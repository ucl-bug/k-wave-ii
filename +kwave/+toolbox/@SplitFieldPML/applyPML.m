%% Apply PML
% *Package:* kwave.toolbox
% *Class:* kwave.toolbox.SplitFieldPML
%
% Apply PML to a vector field.
%
%% Syntax
%   f = applyPML(obj, f, options)
%
%% Description
% Applies the PML variables stored in a |SplitFieldPML| object to a vector
% field |f|, where the Cartesian components of the field are stored in the
% fourth dimension. The x-direction PML is applied to the x-component of
% the field, and so on. If |Staggered=false| (the default), the PML defined
% by |obj.pmlX| (etc) is applied. If |Staggered=true|, the PML defined by
% obj.pmlXStaggered (etc) is applied.
%
%% Input Arguments
% * |f| - (numeric) Vector field to apply the PML to.
%
%% Name-Value Arguments
% Specify optional pairs of arguments as |Name1=Value1,...,NameN=ValueN|,
% where |Name| is the argument name and |Value| is the corresponding value.
% Name-value arguments must appear after other arguments, but the order of
% the pairs does not matter.
%
% * |Staggered| - (logical) If true, the staggered grid PML profiles are
%   used. Default = false.
%
%% Output Arguments
% * |f| - (numeric) Vector field with the PML applied.

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

function f = applyPML(obj, f, options)

arguments
    obj
    f
    options.Staggered(1,1) logical = false
end

if options.Staggered
    for dimInd = 1:obj.kgrid.dimensions
        switch dimInd
            case 1
                f(:, :, :, 1) = obj.privatePmlXStaggered .* f(:, :, :, 1);
            case 2
                f(:, :, :, 2) = obj.privatePmlYStaggered .* f(:, :, :, 2);
            case 3
                f(:, :, :, 3) = obj.privatePmlZStaggered .* f(:, :, :, 3);
        end
    end
else
    for dimInd = 1:obj.kgrid.dimensions
        switch dimInd
            case 1
                f(:, :, :, 1) = obj.privatePmlX .* f(:, :, :, 1);
            case 2
                f(:, :, :, 2) = obj.privatePmlY .* f(:, :, :, 2);
            case 3
                f(:, :, :, 3) = obj.privatePmlZ .* f(:, :, :, 3);
        end
    end
end
