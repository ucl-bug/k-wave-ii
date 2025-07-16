%% BuildMaterialTable
% *Package:* kwave.toolbox
%
% Builds the defaulf Material Table for the medium class.
%
%% Syntax
%   MatTab = BuildMaterialTable()
%
%% Description
% * |BuildMaterialTable| constructs a default 6x7 matrix of parameter
% values according to given materials.
% Parameter values are gven for a particular material aas a 1x7 vector
% containing, in order:
%   soundSpeed (Acoustic)
%   density (Acoustic and Thermal)
%   absorptionCoeff (Acoustic)
%   absorptionPower (Acoustic)
%   BonA (Acoustic)
%   specificHeat (Thermal)
%   thermalConductivity (Thermal)
% New materials may be added in this way appended onto the Build Material
% Table, or other construction, however this parameter order remains fixed.
% Current matierials given are for testing only;
% With a general Acoustic and Themermal test case (1,:)
%   Acoustic test case 2 (2,:)
%   Acoustic Test Case 3 (3,:)
%   Acoustic Test Case 4 (4,:)
%   Random values at time of table generation (5,:)
%   All Zeros (6,:)
% parameter values not required for the problem type may be set to zero,
% however in general this is not the case.
%
%% Input Arguments
%
%% Output Arguments
% * |MtTab| - (numeric) 6x7 matrix of parameter values.
%
%% See Also
% * |Medium|

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

