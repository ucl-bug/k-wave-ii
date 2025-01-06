function MatTab = BuildMaterialTable()
%BUILDMATERIALTABLE Summary of this function goes here
%   Detailed explanation goes here

%inputArg1 will be a vector of integer values that restricts which
%materials are passed to minimise storage of un-needed materials

MatTab=zeros(6,7);
MatTab(1,:)=[1500    ,1000    ,10    ,1.9,0,0,0]; % Test Acoustic 1
MatTab(2,:)=[1500/0.9,1000    ,10    ,1.9,0,0,0]; % Test Acoustic 2
MatTab(3,:)=[1500    ,1000/1.1,10    ,1.9,0,0,0]; % Test Acoustic 3
MatTab(4,:)=[1500    ,1000    ,10/1.1,1.9,0,0,0]; % Test Acoustic 4
MatTab(5,:)=rand(1,7); % Random Values
MatTab(6,:)=0; % All Zero

MatTab=single(MatTab(:,:));

end

