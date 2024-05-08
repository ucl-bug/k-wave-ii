%% ElectromagneticSource
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.GridInput
%
% Class used to define the sources for an electromagnetic simulation.
%
%% Syntax
%   source = ElectromagneticSource(kgrid);
%
%% Description
% This class is used to define the source terms to Maxwell's equations. The
% constructor takes an object of the |kwave.toolbox.Grid| class which
% defines the grid size. The first three source dimensions must match the
% grid size defined by kgrid, with the fourth dimension being used for
% vector components. The number of vector components much match
% |kgrid.dimensions|.  
%
% When using staggered grids, the components of |initialElectricField| and
% |electricCurrentDensitySource| must be defined on the staggered grid
% given by   
% x-component initialElectricField(:,:,:,1) on (0, +1/2, +1/2)
% y-component initialElectricField(:,:,:,2) on (+1/2, 0, +1/2)
% z-component initialElectricField(:,:,:,3) on (+1/2, +1/2, 0)
% 
% When using staggered grids, the components of |initialMagneticField| and
% |magneticCurrentDensitySource| must be defined on the staggered grid
% given by   
% x-component initialMagneticField(:,:,:,1) on (+1/2, 0, 0)
% y-component initialMagneticField(:,:,:,2) on (0, +1/2, 0)
% z-component initialMagneticField(:,:,:,3) on (0, 0, +1/2)
% 
%% Examples
% Define the grid and source objects, and assign an initial electric field.
%
%    kgrid = kwave.toolbox.Grid([128, 128], 1e-3);
%    source = kwave.toolbox.ElectromagneticSource(kgrid);
%    source.initialElectricField = rand([source.gridSize, 2]);
%
%% Properties
% * |initialElectricField|          - Initial electric field vector distribution [V/m].
% * |initialMagneticField|          - Initial magnetic field vector distribution [A/m].
% * |electricCurrentDensitySource|  - Electric current density vector source [A/m^2].
% * |magneticCurrentDensitySource|  - Magnetic current density vector source [T].
%
%% See Also
% * |GridInput|

classdef ElectromagneticSource < kwave.toolbox.GridInput

    properties(Constant, Hidden=true)
        requiredProperties = {};
        gridFields = kwave.toolbox.GridField.createGridFieldsMap([
            kwave.toolbox.GridField('initialElectricField', Attributes={'real', 'finite'}, Type={'VectorField'}) % E field
            kwave.toolbox.GridField('initialMagneticField', Attributes={'real', 'finite'}, Type={'VectorField'}) % H field
            kwave.toolbox.GridField('electricCurrentDensitySource', Attributes={'real', 'finite'}, Type={'VectorField'}) % J source
            kwave.toolbox.GridField('magneticCurrentDensitySource', Attributes={'real', 'finite'}, Type={'VectorField'}) % M source
        ]);
    end

end
