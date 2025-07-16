%% AcousticSource
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.GridInput
%
% Class used to define the acoustic sources for a simulation.
%
%% Syntax
%   source = AcousticSource(kgrid);
%
%% Description
% This class is used to define the acoustic source terms. The constructor
% takes an object of the |kwave.toolbox.Grid| class which defines the grid
% size. Source matrices must match the grid size defined by kgrid.
%
%% Examples
% Define the grid and source objects, and assign the initial pressure.
%
%    kgrid = kwave.toolbox.Grid([128, 128], 1e-3);
%    source = kwave.toolbox.AcousticSource(kgrid);
%    source.initialPressure = rand(source.gridSize);
%
%% Properties
% * |initialPressure| - (numeric) Initial pressure distribution [Pa]. This
%   assumes the initial particle velocity is zero, which is a equivalent to
%   a photoacoustic source under the conditions of stress confinement.
%
%% See Also
% * |GridInput|

classdef AcousticSource < kwave.toolbox.GridInput

    properties(Constant, Hidden=true)
        requiredProperties = {'initialPressure'};
        gridFields = kwave.toolbox.GridField.createGridFieldsMap([
            kwave.toolbox.GridField('initialPressure', Attributes={'real', 'finite'})
            kwave.toolbox.GridField('initialVelocity', Attributes={'real', 'finite'}, Type=kwave.toolbox.GridFieldType.VectorField)
        ]);
    end

end
