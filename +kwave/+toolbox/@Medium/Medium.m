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
% Medium object maps these material indices to the corresponding
% material properties using the lookup table in the |Materials| object.
%
% All grid-valued medium properties (listed below) are registered as
% *GridInput* virtual properties. This means:
%   * Reading |medium.prop| returns the **unpadded** map.
%   * A hidden **padded** backing store |medium.propPadded| is created
%     automatically and used internally by solvers when required.
%
%% Properties
%
% * |materialIndexGrid| — A uint8 array with the same size as the grid.
%   Each element stores a material index referring to an entry in the
%   associated |kwave.toolbox.Materials| object.
%
% Grid-valued virtual properties (unpadded by default, padded versions
% available internally as |...Padded|):
%
% * |soundSpeed|              — [m/s]
% * |density|                 — [kg/m^3]
% * |absorptionCoeff|         — power‑law absorption prefactor [dB/cm/MHz^y]
% * |absorptionPowerMap|      — power‑law exponent y [dimensionless]
% * |BonA|                    — nonlinearity parameter B/A [dimensionless]
% * |specificHeat|            — specific heat capacity [J/(kg·K)]
% * |thermalConductivity|     — thermal conductivity [W/(m·K)]
%
% Scalar properties (user-settable; default computed on first map build):
%
% * |referenceSoundSpeed| — scalar. Default = max(soundSpeed(:))
% * |referenceDiffusion|  — scalar. Default = max(thermalConductivity ./ ...
%                              (density .* specificHeat))
%
% These are set automatically the first time the derived maps are built
% (e.g., when |materialIndexGrid| is first assigned). If the user later
% assigns a value to either scalar, that value is preserved on subsequent
% updates to the maps (i.e., not auto-overwritten).
%
% Note: The acoustic solver uses the single scalar value |absorptionPower|
% at all voxels (algorithmic constraint).
%
%% See Also
% * |Grid|
% * |Materials|

classdef Medium < kwave.toolbox.GridInput
    % Medium class with one user-set virtual property (materialIndexGrid),
    % and a set of read-only derived grid-valued virtual properties whose
    % padded counterparts (propPadded) are managed via GridInput.

    % -------------------------
    % Configuration (constants)
    % -------------------------
    properties(Constant, Hidden=true)
        % One user-assignable virtual property
        requiredProperties = {'materialIndexGrid'};

        % All virtual grid fields (user-assignable + derived read-only)
        gridFields = kwave.toolbox.GridField.createGridFieldsMap([ ...
            kwave.toolbox.GridField('materialIndexGrid', ...
            Classes={'uint8'}, ...
            Attributes={'nonnegative'}, ...
            Type=kwave.toolbox.GridFieldType.ScalarField), ...
            kwave.toolbox.GridField('soundSpeed', ...
            Classes={'single'}, Attributes={'real'}, ...
            Type=kwave.toolbox.GridFieldType.ScalarField), ...
            kwave.toolbox.GridField('density', ...
            Classes={'single'}, Attributes={'real'}, ...
            Type=kwave.toolbox.GridFieldType.ScalarField), ...
            kwave.toolbox.GridField('absorptionCoeff', ...
            Classes={'single'}, Attributes={'real'}, ...
            Type=kwave.toolbox.GridFieldType.ScalarField), ...
            kwave.toolbox.GridField('absorptionPowerMap', ...
            Classes={'single'}, Attributes={'real'}, ...
            Type=kwave.toolbox.GridFieldType.ScalarField), ...
            kwave.toolbox.GridField('BonA', ...
            Classes={'single'}, Attributes={'real'}, ...
            Type=kwave.toolbox.GridFieldType.ScalarField), ...
            kwave.toolbox.GridField('specificHeat', ...
            Classes={'single'}, Attributes={'real'}, ...
            Type=kwave.toolbox.GridFieldType.ScalarField), ...
            kwave.toolbox.GridField('thermalConductivity', ...
            Classes={'single'}, Attributes={'real'}, ...
            Type=kwave.toolbox.GridFieldType.ScalarField) ...
            ]);

        DERIVED_GRID_KEYS = { ...
            'soundSpeed','density','absorptionCoeff','absorptionPowerMap', ...
            'BonA','specificHeat','thermalConductivity' ...
            };
    end

    properties(Dependent=true, SetAccess=private)
        absorptionPower    % mode(absorptionPowerMap), ignoring NaNs
    end

    % -------------------------
    % External handles
    % -------------------------
    properties(SetAccess=immutable, Hidden=true)
        materials(1,1) kwave.toolbox.Materials
    end

    % -------------------------
    % Scalars (user-settable)
    % -------------------------
    properties
        soundSpeedReference (1,1) double {mustBeNonnegative, mustBeFinite}
        diffusionReference  (1,1) double {mustBeNonnegative, mustBeFinite}
    end

    % =========================
    % Constructor
    % =========================
    methods
        function obj = Medium(kgrid, materials)
            arguments
                kgrid(1,1)     kwave.toolbox.Grid
                materials(1,1) kwave.toolbox.Materials
            end
            obj@kwave.toolbox.GridInput(kgrid);   % installs ...Padded backing props
            obj.materials = materials;
        end
    end


    % =========================
    % Override assignment
    % =========================
    methods
        function obj = subsasgn(obj, S, value)
            % Make derived grid properties read-only; only materialIndexGrid
            % (and non-virtual/base properties) can be set by the user.
            if (S(1).type == '.') && ischar(S(1).subs)
                propName = S(1).subs;

                % Block assignment to derived maps
                if ismember(propName, obj.DERIVED_GRID_KEYS)
                    error('Medium:ReadOnlyProperty', ...
                        'The property "%s" is read-only and cannot be assigned.', propName);
                end

                % Intercept assignments to materialIndexGrid to refresh maps
                if strcmp(propName, 'materialIndexGrid')

                    % Delegate to GridInput to perform validation + padding
                    obj = subsasgn@kwave.toolbox.GridInput(obj, S, value);
                    % Recompute all derived maps and write their padded backing stores
                    obj = obj.updateDerivedPaddedMaps();
                    return
                end
            end

            % Fallback to the superclass handling
            obj = subsasgn@kwave.toolbox.GridInput(obj, S, value);
        end
    end

    % =========================
    % Public refresh utility
    % =========================
    methods
        function obj = refresh(obj)
            % Force a rebuild of all derived padded maps (e.g., after Materials changes).
            obj = obj.updateDerivedPaddedMaps();
        end
    end

    % =========================
    % Setters
    % =========================

    methods
        function set.soundSpeedReference(obj, v)
            if ~isempty(v)
                validateattributes(v, {'double'}, {'scalar','finite','nonnegative'});
            end
            obj.soundSpeedReference = v;
        end
        function set.diffusionReference(obj, v)
            if ~isempty(v)
                validateattributes(v, {'double'}, {'scalar','finite','nonnegative'});
            end
            obj.diffusionReference = v;
        end
    end

    % =========================
    % Private helpers
    % =========================
    methods (Access = private)

        function obj = updateDerivedPaddedMaps(obj)
            % Guard: if indices aren't set yet, clear padded maps and return
            idx = obj.subsref(struct('type','.', 'subs','materialIndexGrid'));
            if isempty(idx)
                for i = 1:numel(obj.DERIVED_GRID_KEYS)
                    obj.( [obj.DERIVED_GRID_KEYS{i} 'Padded'] ) = [];
                end
                return
            end

            % name → field mapping (one place to edit)
            mapList = {
                'soundSpeed',          'soundSpeed'
                'density',             'density'
                'absorptionCoeff',     'absorptionCoeff'
                'absorptionPowerMap',  'absorptionPower'   % special: map uses 'absorptionPower'
                'BonA',                'BonA'
                'specificHeat',        'specificHeat'
                'thermalConductivity', 'thermalConductivity'
                };

            % Recompute each derived map and write to its padded backing
            for k = 1:size(mapList,1)
                propName   = mapList{k,1};
                fieldName  = mapList{k,2};
                unpadded   = obj.mapProperty(fieldName);
                paddedName = [propName 'Padded'];
                obj.(paddedName) = obj.kgrid.assignWithGridPadding(unpadded);
            end

            % Only set defaults if the user hasn't assigned them (i.e., still empty)
            if obj.soundSpeedReference == 0
                ss = obj.subsref(struct('type','.', 'subs','soundSpeed'));
                if ~isempty(ss)
                    obj.soundSpeedReference = double(max(ss(~isnan(ss))));
                end
            end

            if obj.diffusionReference == 0
                tc = obj.subsref(struct('type','.', 'subs','thermalConductivity'));
                rho = obj.subsref(struct('type','.', 'subs','density'));
                cp = obj.subsref(struct('type','.', 'subs','specificHeat'));
                if ~(any(isnan(tc(:))) || any(isnan(rho(:))) || any(isnan(cp(:))))
                    denom = rho .* cp;
                    D     = tc ./ denom;
                    obj.diffusionReference = max(D(:));
                end
            end
        end


        function vals = mapProperty(obj, fieldName)

            % Build an unpadded grid-sized map (single) for the given field.
            idx = obj.subsref(struct('type','.', 'subs','materialIndexGrid'));  % uint8, unpadded

            % ensure idx is grid-sized (expand homogeneous scalar)
            if isscalar(idx)
                idx = repmat(idx, obj.gridSize);
            end

            % Look-up table
            lut = NaN(256,1,'single');  % index 0..255

            % Name/Index table (preferred)
            T = obj.materials.listMaterialIndices();  % table: Name, Index
            names   = string(T.Name);
            indices = double(T.Index);

            for k = 1:numel(indices)
                s = obj.materials.(char(names(k)));
                v = s.(fieldName);
                lut(indices(k)+1) = single(v);
            end

            vals = lut(double(idx) + 1);
        end
    end

    % =========================
    % Scalar dependent getters
    % =========================
    methods
            function v = get.absorptionPower(obj)
                % Scalar = mode(absorptionPowerMap) ignoring NaNs.
                apm = obj.subsref(struct('type','.', 'subs','absorptionPowerMap'));  % unpadded
                if isempty(apm)
                    v = NaN;
                    return
                end
                vals = apm(~isnan(apm));
                if isempty(vals)
                    v = NaN;
                    return
                end
                [u, ~, idx] = unique(vals);      % 'u' is single
                counts = accumarray(idx, 1);
                [~, imax] = max(counts);         % smallest mode on ties
                v = u(imax);                     % single
            end

    end
end
