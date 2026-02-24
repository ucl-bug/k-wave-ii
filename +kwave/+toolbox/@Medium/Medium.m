%% Medium
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.GridInput
%
% Class used to define the spatial distribution of material types using
% indices from a |kwave.toolbox.Materials| object, and a grid from a
% |kwave.toolbox.Grid| object.
%
%% Syntax
%   medium = Medium(kgrid, materials);
%
%% Description
% The |Medium| class defines the material properties by specifying, at each
% grid point, an integer material identifier.
%
% All material properties, sound speed, density, etc. are stored in a
% separate |kwave.toolbox.Materials| object. Each material in a |Materials|
% object is assigned a unique uint8 index in the range [0, 255].
%
% The |materialIndexGrid| property is a uint8 array with the same size as
% the computational grid defined by the input |kwave.toolbox.Grid| object.
% Each element specifies which material is present at that point. The
% Medium object then maps these material indices to the corresponding
% material properties using the lookup table contained in the
% |kwave.toolbox.Materials| object.
%
%% Examples
% Create a homogeneous medium filled with water:
%
%    import kwave.toolbox.*
%    kgrid     = Grid([128, 128], 1e-3);
%    materials = Materials();
%    medium    = Medium(kgrid, materials);
%    medium.materialIndexGrid = zeros(kgrid.gridSize, 'uint8');   % "water"
%
% Create a two‑layer medium:
%
%    kgrid     = kwave.toolbox.Grid(128);
%    materials = kwave.toolbox.Materials();
%    medium    = kwave.toolbox.Medium(kgrid, materials);
%    ids       = zeros(kgrid.gridSize, 'uint8');
%    ids(end/2+1:end) = uint8(1);   % air
%    medium.materialIndexGrid = ids;
%
%% Properties
%
% * |materialIndexGrid| — A uint8 array with the same size as the grid.
%   Each element stores a material index referring to an entry in the
%   associated |kwave.toolbox.Materials| object.
%
% Derived material property maps (read‑only, computed on access; each
% returns a numeric array the same size as the grid):
%
% * |soundSpeed|              — [m/s]
% * |density|                 — [kg/m^3]
% * |absorptionCoeff|         — power‑law absorption prefactor [dB/cm/MHz^y]
% * |absorptionPower|         — power‑law exponent y [dimensionless]
% * |BonA|                    — nonlinearity parameter B/A [dimensionless]
% * |specificHeat|            — specific heat capacity [J/(kg·K)]
% * |thermalConductivity|     — thermal conductivity [W/(m·K)]
%
% These getters map the per‑voxel |materialIndexGrid| through the
% corresponding entries stored in the associated |Materials| object.
% Missing values are returned as NaN.
%
%% See Also
%
% * |Grid|
% * |Materials|

classdef Medium < kwave.toolbox.GridInput
    % Medium class with a single user property (materialIndexGrid)
    % and derived material property maps.

    properties(Constant, Hidden=true)
        % Required virtual property
        requiredProperties = {'materialIndexGrid'};

        % Virtual grid field definition
        gridFields = kwave.toolbox.GridField.createGridFieldsMap([ ...
            kwave.toolbox.GridField('materialIndexGrid', ...
                Classes={'uint8'}, ...
                Attributes={'nonnegative','finite'}, ...
                Type=kwave.toolbox.GridFieldType.ScalarField) ...
        ]);
    end

    % Hidden handle to the Materials object
    properties(SetAccess=immutable, Hidden=true)
        materials(1,1) kwave.toolbox.Materials
    end

    % Derived read‑only material properties
    properties(Dependent=true, SetAccess=private)
        soundSpeed
        density
        absorptionCoeff
        absorptionPower
        BonA
        specificHeat
        thermalConductivity
    end

    methods
        function obj = Medium(kgrid, materials)
            %MEDIUM Construct a Medium object.
            %
            %   obj = Medium(kgrid, materials)

            arguments
                kgrid(1,1)     kwave.toolbox.Grid
                materials(1,1) kwave.toolbox.Materials
            end

            obj@kwave.toolbox.GridInput(kgrid);
            obj.materials = materials;
        end
    end

    % ------------------------------------------------------------------
    % Private LUT builder
    % ------------------------------------------------------------------
    methods (Access = private)
        function vals = mapProperty(obj, fieldName)
            %MAPPROPERTY Build a grid-sized map for one material property.
            idx = obj.subsref(struct('type','.', 'subs','materialIndexGrid'));  % uint8, unpadded            
            lut = nan(256,1);              % LUT for indices 0..255

            % Use the table API to get (Name, Index) pairs
            try
                T = obj.materials.listMaterialIndices();  % table
                names   = string(T.Name);
                indices = double(T.Index);
            catch
                % Fallback: derive from dynamic material properties
                props = properties(obj.materials);
                names = strings(0,1); indices = [];
                for i = 1:numel(props)
                    try
                        s = obj.materials.(props{i});
                        if isstruct(s) && isfield(s,'index')
                            names(end+1,1)   = string(props{i}); %#ok<AGROW>
                            indices(end+1,1) = double(s.index);  %#ok<AGROW>
                        end
                    catch
                    end
                end
            end

            % Fill LUT
            for k = 1:numel(indices)
                namek = char(names(k));
                s = obj.materials.(namek);
                if isfield(s, fieldName)
                    v = s.(fieldName);
                    if isnumeric(v) && isscalar(v)
                        lut(indices(k)+1) = double(v);
                    else
                        lut(indices(k)+1) = nan;
                    end
                else
                    lut(indices(k)+1) = nan;
                end
            end

            % Build the voxel map
            vals = lut(double(idx) + 1);
        end
    end

    % ------------------------------------------------------------------
    % Dependent property getters
    % ------------------------------------------------------------------
    methods
        function v = get.soundSpeed(obj)
            v = obj.mapProperty('soundSpeed');
        end
        function v = get.density(obj)
            v = obj.mapProperty('density');
        end
        function v = get.absorptionCoeff(obj)
            v = obj.mapProperty('absorptionCoeff');
        end
        function v = get.absorptionPower(obj)
            v = obj.mapProperty('absorptionPower');
        end
        function v = get.BonA(obj)
            v = obj.mapProperty('BonA');
        end
        function v = get.specificHeat(obj)
            v = obj.mapProperty('specificHeat');
        end
        function v = get.thermalConductivity(obj)
            v = obj.mapProperty('thermalConductivity');
        end
    end
end