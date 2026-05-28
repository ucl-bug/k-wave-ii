%% TestElasticMedium
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.AbstractTestGridInput
%
% Unit tests for the ElasticMedium class using the TestMedium class.

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

classdef TestElasticMedium < kwave.tests.unit.AbstractTestGridInput

    properties
        inputClass = 'ElasticMedium'
        inputProperties = {'density', 'soundSpeedCompression', 'soundSpeedShear', ...
                           'alphaCoeffCompression', 'alphaCoeffShear'}
        inputPropertiesPadded = {'densityPadded', 'soundSpeedCompressionPadded', 'soundSpeedShearPadded', ...
                           'alphaCoeffCompressionPadded', 'alphaCoeffShearPadded'}
        inputPropertiesScalar = {}
        inputPropertiesComplex = {}
        inputPropertiesVectorField = {}
    end

    methods(Test)
    end

end
