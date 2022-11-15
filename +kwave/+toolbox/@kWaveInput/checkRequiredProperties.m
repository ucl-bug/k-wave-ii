%% checkRequiredProperties
% *Class:* kwave.toolbox.kWaveInput
% *Package:* kwave.toolbox
%
% Check required properties of input object are defined.
%
%% Syntax
%   checkRequiredProperties(obj)
%
%% Description
% Checks the required properties, defined by the cell array
% |obj.requiredProperties|, are not empty. This method is called by the
% |kWaveSolver| constructor.

function checkRequiredProperties(obj)

for ind = 1:length(obj.requiredProperties)
    if isempty(obj.(obj.requiredProperties{ind}))
        error('kWaveInput:missingInput', ['The property ' obj.requiredProperties{ind} ' must be defined.']);
    end
end
