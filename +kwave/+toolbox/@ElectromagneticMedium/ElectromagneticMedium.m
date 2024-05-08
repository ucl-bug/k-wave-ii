%% ElectromagneticMedium
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.GridInput
%
% Class used to define the electromagnetic medium properties for a
% simulation using Maxwell's equations. 
%
%% Syntax
%   medium = ElectromagneticMedium(kgrid);
%
%% Description
% This class is used to define the electromagnetic medium properties
% required for a simulation based on Maxwell's equations. The simulation is
% limited to isotropic, linear materials so these must be scalar fields.
% The constructor takes an object of the |kwave.toolbox.Grid| class which
% defines the grid size.  
%
%% Examples
% Define the grid and medium objects, and assign the electromagnetic
% properties. 
%
%    kgrid  = kwave.toolbox.Grid([128, 128, 128], 1e-3);
%    medium = kwave.toolbox.ElectromagneticMedium(kgrid);
%    medium.permittivity = rand(medium.gridSize);
%    medium.permeability = rand(medium.gridSize);
%    medium.conductivity = rand(medium.gridSize);
%
%% Properties
% * |permittivity| - (isotropic) permittivity [F/m].
% * |permeability| - (isotropic) permeability [H/m].
% * |conductivity| - (isotropic) conductivity [S/m].
%
%% See Also
% * |GridInput|

classdef ElectromagneticMedium < kwave.toolbox.GridInput

    properties(Constant, Hidden=true)
        requiredProperties = {'permittivity','permeability'};
        gridFields = kwave.toolbox.GridField.createGridFieldsMap([
            kwave.toolbox.GridField('permittivity');
            kwave.toolbox.GridField('permeability');
            kwave.toolbox.GridField('conductivity');
        ]);
    end

end
