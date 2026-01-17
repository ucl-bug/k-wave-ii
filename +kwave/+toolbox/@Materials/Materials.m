%% Materials
% *Package:* kwave.toolbox
%
% Class for holding material property structures.
%
%% Syntax
%   materials = Materials();
%
%% Description
% Class for holding material property structures so that materials can be
% referenced using a single index. Used by Medium class. Initialised with
% some default materials, but additional materials can be added. Each
% material structure within the Materials object must have at least the
% fields: 
% * soundSpeed [m/s]
% * density    [kg/m^3]
% but may also have:
% * absorption coefficient prefactor (alpha0) [dB/cm/MHz^y]
% * absorption power law exponent (y)
% * nonlinearity parameter B/A (BonA)
% * specific heat capacity (C) [J/kg/K]
% * thermal conductivity (k_cond) [W/m/K]
% 
% For example, one of the default structures is water
% * materials.water.soundSpeed
% * materials.water.density
% * materials.water.absorptionCoeff
% * materials.water.absorptionPower
% * materials.water.BonA
% * materials.water.specificHeatCapacity
% * materials.water.thermalConductivity

%% Examples
%
%   materials = Materials();
%   T = materials.listMaterials()
%   I = materials.listMaterialIndices()
%   materials.addMaterial('softTissue', Materials.makeMaterial(3, 1540, 1000));
%
%% Properties
% 
% * Structures, named for the material, containing the values of the
%   material properties. 
%
%% See Also
% 
% * |Medium|

classdef Materials < dynamicprops

    properties (Constant, Access = private)
        % Required and optional field sets
        REQUIRED_FIELDS = {'index','soundSpeed','density'};
        OPTIONAL_FIELDS = {'absorptionCoeff',...
                           'absorptionPower',...
                           'BonA', ...
                           'specificHeat',...
                           'thermalConductivity'};

        % For filtering non-material properties
        RESERVED_PROPS = {'REQUIRED_FIELDS','OPTIONAL_FIELDS','RESERVED_PROPS'};
    end

    methods
        function obj = Materials()
            % Pre-populate with two examples (types are enforced on add).
            water = struct( ...
                'index',               uint8(1), ...
                'soundSpeed',          1480, ...   % m/s @ ~20°C
                'density',             1000, ...   % kg/m^3
                'absorptionCoeff',     0.5, ...    % dB/cm/MHz^y
                'absorptionPower',     2, ...      % (y) dimensionless
                'BonA',                5, ...      % dimensionless
                'specificHeat',        4181, ...   % J/(kg·K)
                'thermalConductivity', 0.58 );     % W/(m·K)
            obj.addMaterial('water', water);

            air = struct( ...
                'index',               uint8(2), ...
                'soundSpeed',          343, ...
                'density',             1.225, ...
                'absorptionCoeff',     NaN, ...    % leave optional as NaN if unknown
                'absorptionPower',     NaN, ...
                'BonA',                0.7, ...
                'specificHeat',        1005, ...
                'thermalConductivity', 0.026 );
            obj.addMaterial('air', air);
        end

        function obj = addMaterial(obj, name, s)
            %ADDMATERIAL Add a new material as a dynamic property with validation.
            %
            %   obj.addMaterial('tissue', struct(...))
            %
            % Validates:
            %   - name is a valid MATLAB identifier and not already used
            %   - required fields exist (index, soundSpeed, density)
            %   - types/sizes/sign constraints per spec; optional fields may be NaN or absent
            %   - index is uint8, positive, and unique across materials

            % Check material name validity
            if ~kwave.toolbox.Materials.isValidMaterialName(name)
                error('Materials:InvalidName', ...
                    'Material name "%s" is not a valid MATLAB identifier.', name);
            end
            if isprop(obj, name)
                error('Materials:DuplicateName', ...
                      'A material named "%s" already exists.', name);
            end

            % Validate & canonicalize (coerce classes, add missing optionals as NaN)
            s = kwave.toolbox.Materials.canonicalizeAndValidateStruct(s);

            % Enforce unique index
            existingIdx = double(obj.getAllIndices()); % compare in double space
            if any(existingIdx == double(s.index))
                error('Materials:DuplicateIndex', ...
                      'Index %d is already used by another material.', s.index);
            end

            % Create dynamic property and assign struct
            p = addprop(obj, name);
            p.GetAccess = 'public';
            p.SetAccess = 'public';
            obj.(name) = s;
        end

        function T = listMaterials(obj)
            %LISTMATERIALS Return a table of all materials and their standard properties.
            names = obj.getMaterialNames();
            cols = [obj.REQUIRED_FIELDS, obj.OPTIONAL_FIELDS];
            n = numel(names);

            % Pre-allocate as single/double appropriately
            idxCol = NaN(n,1,'double');  % display as double for readability
            data   = NaN(n, numel(cols)-1, 'single');

            for i = 1:n
                s = obj.(names{i});
                % index (cast to double for the table)
                idxCol(i) = double(s.index);

                % remaining fields in declared order
                for j = 2:numel(cols)
                    f = cols{j};
                    if isfield(s, f)
                        v = s.(f);
                        if isnumeric(v) && isscalar(v)
                            data(i, j-1) = single(v);
                        else
                            data(i, j-1) = single(NaN);
                        end
                    else
                        data(i, j-1) = single(NaN);
                    end
                end
            end

            % Build table
            varNames = [{'Name'}, cols];
            T = table( string(names(:)), idxCol, data(:,1), data(:,2), data(:,3), ...
                       data(:,4), data(:,5), data(:,6), data(:,7), ...
                       'VariableNames', varNames);
        end

        function I = listMaterialIndices(obj)
            %LISTMATERIALINDICES Return Name-Index mapping as a table.
            names = obj.getMaterialNames();
            idx = zeros(numel(names),1,'double');
            for i = 1:numel(names)
                idx(i) = double(obj.(names{i}).index);
            end
            I = table( string(names(:)), idx, 'VariableNames', {'Name','Index'} );
        end
    end

    methods (Access = private)
        function names = getMaterialNames(obj)
            %GETMATERIALNAMES Return only dynamic material property names.
            allProps = properties(obj);
            names = setdiff(allProps, obj.RESERVED_PROPS, 'stable');

            % keep only those that look like material structs (have 'index' field)
            isMaterial = false(size(names));
            for i = 1:numel(names)
                try
                    val = obj.(names{i});
                    isMaterial(i) = isstruct(val) && isfield(val,'index');
                catch
                    isMaterial(i) = false;
                end
            end
            names = names(isMaterial);
        end

        function idx = getAllIndices(obj)
            %GETALLINDICES Collect indices from all materials as double vector.
            names = obj.getMaterialNames();
            idx = zeros(numel(names),1,'double');
            for i = 1:numel(names)
                idx(i) = double(obj.(names{i}).index);
            end
        end
    end

    methods (Static, Access = private)
        function s = canonicalizeAndValidateStruct(s)
            % Ensure required fields exist
            req = kwave.toolbox.Materials.REQUIRED_FIELDS;
            missing = setdiff(req, fieldnames(s));
            if ~isempty(missing)
                error('Materials:MissingFields', ...
                    'Material struct is missing required fields: %s', strjoin(missing, ', '));
            end

            % Fill any missing optional fields with single(NaN)
            opt = kwave.toolbox.Materials.OPTIONAL_FIELDS;
            for k = 1:numel(opt)
                f = opt{k};
                if ~isfield(s, f) || isempty(s.(f))
                    s.(f) = single(NaN);
                end
            end

            % ---- Validate & coerce each field ----

            % index: (1,1) uint8, positive, finite, unique handled elsewhere
            s.index = kwave.toolbox.Materials.ensureUint8PositiveScalar(s.index, 'index');

            % soundSpeed: (1,1) single, positive, finite
            s.soundSpeed = kwave.toolbox.Materials.ensureNumericScalar(s.soundSpeed, 'soundSpeed', ...
                                                        'positive', true);

            % density: (1,1) single, positive, finite
            s.density    = kwave.toolbox.Materials.ensureNumericScalar(s.density, 'density', ...
                                                        'positive', true);

            % Optional numeric fields:
            % absorptionCoeff: (1,1) single, nonneg, finite if provided (NaN allowed)
            s.absorptionCoeff = kwave.toolbox.Materials.ensureNumericOptional(s.absorptionCoeff, ...
                                        'absorptionCoeff', 'nonnegative');

            % absorptionPower: (1,1) single, nonneg, finite if provided (NaN allowed)
            s.absorptionPower = kwave.toolbox.Materials.ensureNumericOptional(s.absorptionPower, ...
                                        'absorptionPower', 'nonnegative');

            % BonA: (1,1) single, nonneg, finite if provided (NaN allowed)
            s.BonA = kwave.toolbox.Materials.ensureNumericOptional(s.BonA, 'BonA', 'nonnegative');

            % specificHeat: (1,1) single, positive, finite if provided (NaN allowed)
            s.specificHeat = kwave.toolbox.Materials.ensureNumericOptional(s.specificHeat, ...
                                        'specificHeat', 'positive');

            % thermalConductivity: (1,1) single, positive, finite if provided (NaN allowed)
            s.thermalConductivity = kwave.toolbox.Materials.ensureNumericOptional(s.thermalConductivity, ...
                                        'thermalConductivity', 'positive');
        end

        function v = ensureUint8PositiveScalar(v, fname)
            % Accept numeric scalar that can be safely cast to uint8 and is >=1
            if ~(isnumeric(v) && isscalar(v) && isfinite(v))
                error('Materials:InvalidField', ...
                    '"%s" must be a finite numeric scalar.', fname);
            end
            if v <= 0 || v ~= floor(v)
                error('Materials:InvalidIndex', ...
                    '"%s" must be a positive integer value >= 1.', fname);
            end
            if v > double(intmax('uint8'))
                error('Materials:IndexRange', ...
                    '"%s" exceeds uint8 range (max %d).', fname, intmax('uint8'));
            end
            v = uint8(v);
        end

        function v = ensureNumericScalar(v, fname, signConstraint, mustBeFiniteFlag)
            % Coerce to single and enforce sign + finiteness
            if ~(isnumeric(v) && isscalar(v))
                error('Materials:InvalidField', ...
                    '"%s" must be a numeric scalar.', fname);
            end
            if mustBeFiniteFlag && ~isfinite(v)
                error('Materials:InvalidField', ...
                    '"%s" must be finite.', fname);
            end
            switch signConstraint
                case 'positive'
                    if ~(v > 0)
                        error('Materials:InvalidField', ...
                            '"%s" must be > 0.', fname);
                    end
                case 'nonnegative'
                    if ~(v >= 0)
                        error('Materials:InvalidField', ...
                            '"%s" must be >= 0.', fname);
                    end
                otherwise
                    % no-op
            end
        end

        function v = ensureNumericOptional(v, fname, signConstraint)
            % Optional fields: allow NaN (default/missing), otherwise enforce finite + sign.
            if ~(isnumeric(v) && isscalar(v))
                error('Materials:InvalidField', ...
                    '"%s" must be a numeric scalar (or NaN).', fname);
            end
            if isnan(v)
                return;   % accept NaN as-is (no finiteness or sign checks)
            end

            if ~isfinite(v)
                error('Materials:InvalidField', '"%s" must be finite (or NaN).', fname);
            end
            switch signConstraint
                case 'positive'
                    if ~(v > 0)
                        error('Materials:InvalidField', '"%s" must be > 0 (or NaN).', fname);
                    end
                case 'nonnegative'
                    if ~(v >= 0)
                        error('Materials:InvalidField', '"%s" must be >= 0 (or NaN).', fname);
                    end
            end
        end

        function tf = isValidMaterialName(name)
            tf = (ischar(name) || (isstring(name) && isscalar(name)));
            if tf, tf = isvarname(char(name)); end
        end
    end

    methods (Static)
        function s = makeMaterial(index, soundSpeed, density, ...
                                  absorptionCoeff, absorptionPower, BonA, ...
                                  specificHeat, thermalConductivity)
            %MAKEMATERIAL Convenience constructor for a material struct.
            %
            % Positional parameters:
            %   index, soundSpeed, density    -> required
            %   absorptionCoeff, absorptionPower, BonA, specificHeat, thermalConductivity -> optional
            %
            % Missing optionals default to single(NaN).

            if nargin < 3
                error('Materials:makeMaterial', ...
                    'Provide at least index, soundSpeed, and density.');
            end

            % Default optional arguments to NaN
            if nargin < 4, absorptionCoeff = single(NaN); end
            if nargin < 5, absorptionPower = single(NaN); end
            if nargin < 6, BonA            = single(NaN); end
            if nargin < 7, specificHeat    = single(NaN); end
            if nargin < 8, thermalConductivity = single(NaN); end

            s = struct( ...
                'index',               index, ...
                'soundSpeed',          soundSpeed, ...
                'density',             density, ...
                'absorptionCoeff',     absorptionCoeff, ...
                'absorptionPower',     absorptionPower, ...
                'BonA',                BonA, ...
                'specificHeat',        specificHeat, ...
                'thermalConductivity', thermalConductivity );
        end
    end
end
