function MatTab = BuildMaterialTable
%BUILDMATERIALTABLE Summary of this function goes here
%   Detailed explanation goes here

%inputArg1 will be a vector of integer values that restricts which
%materials are passed to minimise storage of un-needed materials

% Variables given in the order
% 
% Sound Speed
% Density
% acoustic absorption coefficiient
% acoustic absorption Power
% acounstic B on A
% specific Heat
% Thermal Conductivity

MatTab=zeros(3,7);
MatTab(1,:)=[1500,1000,0.5,1.1,0,3540,0.52]; % Base Acoustic 1
MatTab(2,:)=rand(1,7); % Random Values
MatTab(3,:)=0; % All Zero

MatTab=single(MatTab(:,:));

end

