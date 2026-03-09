%% TestMedium
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.AbstractTestGridInput
%
% Unit tests for the Medium class using the TestMedium class.

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

classdef TestMedium < kwave.tests.unit.AbstractTestGridInput

    properties
        inputClass = 'Medium'
        inputProperties = {'materialIDGrid'}
        inputPropertiesPadded = {'materialIDGridPadded'}
        inputPropertiesScalar = {'soundSpeedReference', 'diffusionReference'}
        inputPropertiesComplex = {}
        inputPropertiesVectorField = {'materialTable'}
    end

    %Unpadded methods call the padded methods
    methods(Test, ParameterCombination="sequential")
        
        function callVariablesTest(testCase)

            import kwave.toolbox.*

            mediumConstant = Medium(testCase.kgrid);
            mediumVaried = Medium(testCase.kgrid);
            mediumConstant.materialIDGrid=1;
            mediumVaried.materialIDGrid= ones(testCase.kgrid.gridSize);
            mediumVaried.materialIDGrid(1)=2;
            mediumVaried.BonA;
            mediumVaried.density;
            mediumVaried.soundSpeed;
            mediumVaried.specificHeat;
            mediumVaried.thermalConductivity;
            mediumVaried.absorptionCoeff;
            mediumVaried.absorptionPower;
            mediumConstant.BonA;
            mediumConstant.density;
            mediumConstant.soundSpeed;
            mediumConstant.specificHeat;
            mediumConstant.thermalConductivity;
            mediumConstant.absorptionCoeff;
            mediumConstant.absorptionPower;
        end

    end

end
