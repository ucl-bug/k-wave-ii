%% Medium
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.GridInput
%
% Class used to define the medium properties via a table of material
% properties.  
%
%% Syntax
%   medium = Medium(kgrid);
%
%% Description
% Class used to define medium properties from table of material properties 
% given a grid containing material identifiers. The constructor takes an
% object of the |kwave.toolbox.Grid| class, which defines the grid size. 
%
%
%% Examples
% Define the grid and medium objects, and assign the type of material.
%
%    kgrid  = kwave.toolbox.Grid([128, 128], 1e-3);
%    medium = kwave.toolbox.Medium(kgrid);
%    medium.materialIDGrid = ones(kgrid.gridSize); % Water, water everywhere
%
%    kgrid  = kwave.toolbox.Grid(128);
%    medium = kwave.toolbox.Medium(kgrid);
%    medium.materialIDGrid = zeros(kgrid.gridSize);
%    medium.materialIDGrid(1:end/2) = 1;
%    medium.materialIDGrid(end/2+1:end) = 2;
% 
%% Properties
% * |materialIDGrid| - Grid containing indices to material types.
% * |materialTable|  - Table of material properties.
%
%% See Also
% * |GridInput|, |Materials|, |AcousticMedium|, |ThermalMedium|

classdef Medium < kwave.toolbox.GridInput

    properties
        materialTable (:,7) single {mustBeReal, mustBeNonnegative, mustBeFinite} =  kwave.toolbox.materials.getMaterialTable()
        soundSpeedReference single {mustBeReal, mustBePositive, mustBeFinite}
        diffusionReference {mustBeReal, mustBeFinite}
    end

    properties(Constant, Hidden=false)
        requiredProperties = {'materialIDGrid'}; %'soundSpeed', 'density', 'specificHeat', 'thermalConductivity'};
        gridFields = kwave.toolbox.GridField.createGridFieldsMap([
            kwave.toolbox.GridField('materialIDGrid')
            ]);
    end
        
    methods

        soundSpeed          = soundSpeedPadded(obj);
        density             = densityPadded(obj);
        absorptionCoeff     = absorptionCoeffPadded(obj);
        absorptionPower     = absorptionPower(obj);
        BonA                = BonAPadded(obj);
        specificHeat        = specificHeatPadded(obj);
        thermalConductivity = thermalConductivityPadded(obj);
        soundSpeed          = soundSpeed(obj);
        density             = density(obj);
        absorptionCoeff     = absorptionCoeff(obj);
        BonA                = BonA(obj);
        specificHeat        = specificHeat(obj);
        thermalConductivity = thermalConductivity(obj);

        % Add a new material to the materialTable
        function [updatedTable, updatedNames] = addMaterial(obj, newRows, newNames)
            [updatedTable, updatedNames] = kwave.toolbox.materials.addMaterial( ...
                obj.materialTable, newRows, obj.materialNames, newNames);
            obj.materialTable = updatedTable;
            obj.materialNames = updatedNames;
        end

    end

    methods (Static)

        % Returns a matrix of material properties and string vector of names
        function [materialTable, materialNames] = getMaterialTable()
            [materialTable, materialNames] = kwave.toolbox.materials.getMaterialTable();
        end

        % Prints a table showing the built-in material properties
        function materialList = listMaterialTable()
            materialList = kwave.toolbox.materials.listMaterialTable();
        end
    end
end
