%% Build Material Table
% *Package:* kwave.toolbox
%
% Builds the default Material Table for the medium class.
%
%% Syntax
%   MatTab = BuildMaterialTable()
%
%% Description
% |BuildMaterialTable| constructs a default 6x7 matrix of parameter
% values according to given materials.
% Parameter values are given for a particular material as a 1x7 vector
% containing, in order:
%
% *  soundSpeed (Acoustic)
% *  density (Acoustic and Thermal)
% *  absorptionCoeff (Acoustic)
% *  absorptionPower (Acoustic)
% *  BonA (Acoustic)
% *  specificHeat (Thermal)
% *  thermalConductivity (Thermal)
%
% New materials may be added in this way appended onto the Build Material
% Table, or other construction, however this parameter order remains fixed.
% 
% Current materials given are for testing only
%
% *  With a general Acoustic and Thermal test case (1,:)
% *  Acoustic test case 2 (2,:)
% *  Acoustic Test Case 3 (3,:)
% *  Acoustic Test Case 4 (4,:)
% *  Random values at time of table generation (5,:)
% *  All Zeros (6,:)
%
% Parameter values not required for the problem type may be set to zero,
% however in general this is not the case.
%
%% Input Arguments
%
%% Output Arguments
% * |MtTab| - (numeric) 6x7 matrix of parameter values.
%
%% See Also
% * |Medium|

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

function MatTab = BuildMaterialTable()

MatTab=zeros(6,7);
MatTab(1,:)=[1500    ,1000    ,10    ,1.9,0,3540,0.52]; % Test 1
MatTab(2,:)=[1500/0.9,1000    ,10    ,1.9,0,0,0]; % Test Acoustic 2
MatTab(3,:)=[1500    ,1000/1.1,10    ,1.9,0,0,0]; % Test Acoustic 3
MatTab(4,:)=[1500    ,1000    ,10/1.1,1.9,0,0,0]; % Test Acoustic 4
MatTab(5,:)=rand(1,7); % Random Values
MatTab(6,:)=0; % All Zero

MatTab=single(MatTab(:,:));

end

