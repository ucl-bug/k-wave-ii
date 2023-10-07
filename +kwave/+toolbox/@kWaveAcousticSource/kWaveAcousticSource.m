%% kWaveAcousticSource
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.kWaveInput
%
% Class used to define the acoustic sources for a simulation.
%
%% Syntax
%   source = kWaveAcousticSource(kgrid);
%
%% Description
% This class is used to define the acoustic source terms. The constructor
% takes an object of the |kwave.toolbox.kWaveGrid| class which defines the
% grid size. Source matrices must match the grid size defined by kgrid.
%
%% Examples
% Define the grid and source objects, and assign the initial pressure.
%
%    kgrid = kwave.toolbox.kWaveGrid([128, 128], 1e-3);
%    source = kwave.toolbox.kWaveAcousticSource(kgrid);
%    source.initialPressure = rand(source.gridSize);
%
%% Properties
% * |initialPressure| - (numeric) Initial pressure distribution [Pa]. This
%   assumes the initial particle velocity is zero, which is a equivalent to
%   a photoacoustic source under the conditions of stress confinement.
%
%% See Also
% * |kWaveInput|

classdef kWaveAcousticSource < kwave.toolbox.kWaveInput

    properties(Constant, Hidden=true)
        requiredProperties = {};
        gridFields = kwave.toolbox.kWaveInput.createGridFieldsMap([
            struct('name', 'initialPressure', 'classes', {{'numeric'}}, 'attributes', {{'real', 'finite'}})
        ]);
    end

end
