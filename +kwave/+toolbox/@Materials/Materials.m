%% Materials
% *Package:* kwave.toolbox
%
% Class for holding material property structures so that materials can be
% referenced using a single index. Used by the Medium class. Initialised with
% some default materials, but additional materials can be added. Each
% material structure within the Materials object must have at least the
% fields:
%
% * soundSpeed [m/s]
% * density    [kg/m^3]
%
% Optionally, a material may also have:
%
% * absorption coefficient prefactor (alpha0) [dB/cm/MHz^y]
% * absorption power law exponent (y)
% * nonlinearity parameter B/A (BonA)
% * specific heat capacity (C) [J/kg/K]
% * thermal conductivity (k_cond) [W/m/K]
%
% Index handling:
%
% * The 'index' field is optional when adding a material.
% * If omitted, addMaterial auto-assigns the lowest free uint8 index in [0..255].
% * If provided, it must be a unique uint8-compatible integer in [0..255].
%
% Examples
%   materials = Materials();
%   T = materials.listMaterials()
%   I = materials.listMaterialIndices()
%   [materials, idx] = materials.addMaterial('softTissue', struct('soundSpeed',1540,'density',1000));
%   materials.addMaterial('softTissue', struct('index',10,'soundSpeed',1540,'density',1000));
%
% See Also
%
% * |Medium|

classdef Materials < dynamicprops

    properties (Constant, Access = private)
        % Required and optional field sets
        % 'index' is optional now (auto-assigned if missing)
        REQUIRED_FIELDS = {'soundSpeed','density'};
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
                'index',               uint8(0), ... % uint8 limits the number of materials to 256
                'soundSpeed',          single(1480), ...     % m/s @ ~20°C
                'density',             single(1000), ...     % kg/m^3
                'absorptionCoeff',     single(0.5), ...      % dB/cm/MHz^y
                'absorptionPower',     single(2), ...        % (y) dimensionless
                'BonA',                single(5), ...        % dimensionless
                'specificHeat',        single(4181), ...     % J/(kg·K)
                'thermalConductivity', single(0.58) );       % W/(m·K)
            obj.addMaterial('water', water);

            air = struct( ...
                'index',               uint8(1), ...
                'soundSpeed',          single(343), ...
                'density',             single(1.225), ...
                'absorptionCoeff',     single(NaN), ...    % leave optional as NaN if unknown
                'absorptionPower',     single(NaN), ...
                'BonA',                single(0.7), ...
                'specificHeat',        single(1005), ...
                'thermalConductivity', single(0.026) );
            obj.addMaterial('air', air);
        end

        function [obj, assignedIdx] = addMaterial(obj, name, s)
            % ADDMATERIAL Add a new material as a dynamic property with validation.
            %
            %   [obj, idx] = obj.addMaterial('tissue', struct(...))
            %
            % Behavior:
            %   - 'index' is optional; if omitted/empty, the next free uint8 index
            %     in [0,255] is assigned automatically (lowest available).
            %   - If 'index' is provided, it must be uint8-compatible in [0,255]
            %     and unique across materials.
            %
            % Returns:
            %   assignedIdx : the uint8 index assigned to this material.

            % Check material name validity
            if ~kwave.toolbox.Materials.isValidMaterialName(name)
                error('Materials:InvalidName', ...
                    'Material name "%s" is not a valid MATLAB identifier.', name);
            end
            if isprop(obj, name)
                error('Materials:DuplicateName', ...
                    'A material named "%s" already exists.', name);
            end

            % Validate & canonicalize provided fields (index is optional now)
            s = kwave.toolbox.Materials.canonicalizeAndValidateStruct(s);

            % Determine/validate index
            existingIdx = double(obj.getAllIndices()); % compare in double space
            if isfield(s,'index') && ~isempty(s.index)
                % User supplied an index: validate & enforce uniqueness
                s.index = kwave.toolbox.Materials.ensureUint8Index(s.index, 'index');
                if any(existingIdx == double(s.index))
                    error('Materials:DuplicateIndex', ...
                        'Index %d is already used by another material.', s.index);
                end
                assignedIdx = s.index;
            else
                % Auto-assign next available index in [0..255]
                assignedIdx = obj.nextAvailableIndex();
                if isempty(assignedIdx)
                    error('Materials:NoFreeIndex', ...
                        'No free indices available: the 0..255 range is exhausted.');
                end
                s.index = assignedIdx;
            end

            % Ensure all numeric scalar properties are 'single'; keep 'index' as uint8
            s = kwave.toolbox.Materials.castMaterialFieldsToSingle(s);

            % Create dynamic property and assign struct
            p = addprop(obj, name);
            p.GetAccess = 'public';
            p.SetAccess = 'public';
            obj.(name) = s;
        end

        function T = listMaterials(obj)
            % LISTMATERIALS Return a table of all materials and their standard properties,
            % sorted by ascending index.
            [names, idxCol] = obj.getMaterialNamesAndIndicesSorted();

            % Fixed order for display (index is shown as a separate column)
            orderedFields = {'soundSpeed','density', ...
                'absorptionCoeff','absorptionPower','BonA', ...
                'specificHeat','thermalConductivity'};

            n = numel(names);
            data = NaN(n, numel(orderedFields), 'single');

            for i = 1:n
                s = obj.(names{i});

                % Other fields
                for j = 1:numel(orderedFields)
                    f = orderedFields{j};
                    if isfield(s, f)
                        v = s.(f);
                        if isnumeric(v) && isscalar(v)
                            data(i, j) = single(v);
                        else
                            data(i, j) = single(NaN);
                        end
                    else
                        data(i, j) = single(NaN);
                    end
                end
            end

            varNames = [{'Name','Index'}, orderedFields];
            T = table( string(names(:)), double(idxCol(:)), ...
                data(:,1), data(:,2), data(:,3), data(:,4), data(:,5), data(:,6), data(:,7), ...
                'VariableNames', varNames);
        end

        function I = listMaterialIndices(obj)
            % LISTMATERIALINDICES Return Name-Index mapping as a table,
            % sorted by ascending index.
            [names, idx] = obj.getMaterialNamesAndIndicesSorted();
            I = table( string(names(:)), idx(:), 'VariableNames', {'Name','Index'} );
        end
    end

    methods (Access = private)
        function names = getMaterialNames(obj)
            % GETMATERIALNAMES Return only dynamic material property names.
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
            % GETALLINDICES Collect indices from all materials as double vector.
            names = obj.getMaterialNames();
            idx = zeros(numel(names),1,'double');
            for i = 1:numel(names)
                idx(i) = double(obj.(names{i}).index);
            end
        end

        function idx = nextAvailableIndex(obj)
            % NEXTAVAILABLEINDEX Return lowest free uint8 index in [0..255], or [] if none.
            used = double(obj.getAllIndices());
            all  = 0:double(intmax('uint8'));   % 0..255
            free = setdiff(all, used, 'stable'); % keep ascending order
            if isempty(free)
                idx = [];
            else
                idx = uint8(free(1));
            end
        end

        function [namesSorted, idxSorted] = getMaterialNamesAndIndicesSorted(obj)
            %GETMATERIALNAMESANDINDICESSORTED Return material names and indices sorted by index asc.
            names = obj.getMaterialNames();
            idx   = zeros(numel(names),1,'uint8');
            for i = 1:numel(names)
                idx(i) = obj.(names{i}).index;
            end
            [idxSorted, order] = sort(idx, 'ascend');
            namesSorted = names(order);
        end
    end

    methods (Static, Access = private)
        function s = canonicalizeAndValidateStruct(s)

            % Ensure required fields exist (index is optional now)
            req = kwave.toolbox.Materials.REQUIRED_FIELDS;  % {'soundSpeed','density'}
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

            % index: optional; if present, validate here (uniqueness handled in addMaterial)
            if isfield(s, 'index') && ~isempty(s.index)
                s.index = kwave.toolbox.Materials.ensureUint8Index(s.index, 'index');
            end

            % soundSpeed: (1,1) numeric scalar, positive, finite
            s.soundSpeed = kwave.toolbox.Materials.ensureNumericScalar( ...
                s.soundSpeed, 'soundSpeed', 'positive', true);

            % density: (1,1) numeric scalar, positive, finite
            s.density = kwave.toolbox.Materials.ensureNumericScalar( ...
                s.density, 'density', 'positive', true);

            % Optional numeric fields:
            s.absorptionCoeff = kwave.toolbox.Materials.ensureNumericOptional( ...
                s.absorptionCoeff, 'absorptionCoeff', 'nonnegative');

            s.absorptionPower = kwave.toolbox.Materials.ensureNumericOptional( ...
                s.absorptionPower, 'absorptionPower', 'nonnegative');

            s.BonA = kwave.toolbox.Materials.ensureNumericOptional( ...
                s.BonA, 'BonA', 'nonnegative');

            s.specificHeat = kwave.toolbox.Materials.ensureNumericOptional( ...
                s.specificHeat, 'specificHeat', 'positive');

            s.thermalConductivity = kwave.toolbox.Materials.ensureNumericOptional( ...
                s.thermalConductivity, 'thermalConductivity', 'positive');
        end

        function v = ensureUint8Index(v, fname)
            % Accept numeric scalar that can be safely cast to uint8 and is in [0, 255]
            if ~(isnumeric(v) && isscalar(v) && isfinite(v))
                error('Materials:InvalidField', ...
                    '"%s" must be a finite numeric scalar.', fname);
            end
            if v < 0 || v ~= floor(v)
                error('Materials:InvalidIndex', ...
                    '"%s" must be an integer value in the range [0, 255].', fname);
            end
            if v > double(intmax('uint8'))
                error('Materials:IndexRange', ...
                    '"%s" exceeds uint8 range (max %d).', fname, intmax('uint8'));
            end
            v = uint8(v);
        end

        function v = ensureNumericScalar(v, fname, signConstraint, mustBeFiniteFlag)
            if ~(isnumeric(v) && isscalar(v))
                error('Materials:InvalidField', '"%s" must be a numeric scalar.', fname);
            end

            % enforce real values
            if ~isreal(v)
                error('Materials:InvalidField', '"%s" must be a real value.', fname);
            end

            if mustBeFiniteFlag && ~isfinite(v)
                error('Materials:InvalidField', '"%s" must be finite.', fname);
            end

            switch signConstraint
                case 'positive'
                    if ~(v > 0)
                        error('Materials:InvalidField', '"%s" must be > 0.', fname);
                    end
                case 'nonnegative'
                    if ~(v >= 0)
                        error('Materials:InvalidField', '"%s" must be >= 0.', fname);
                    end
                otherwise
                    % no-op
            end
        end


        function v = ensureNumericOptional(v, fname, signConstraint)
            if ~(isnumeric(v) && isscalar(v))
                error('Materials:InvalidField', '"%s" must be a numeric scalar (or NaN).', fname);
            end

            if isnan(v)
                return; % leave NaN as-is
            end

            % enforce real values
            if ~isreal(v)
                error('Materials:InvalidField', '"%s" must be a real value (or NaN).', fname);
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


        function s = castMaterialFieldsToSingle(s)
            % Convert all numeric scalar fields (except 'index') to single.
            % Keep 'index' as uint8. Leave non-scalar or non-numeric fields as-is.

            fields = fieldnames(s);
            for i = 1:numel(fields)
                f = fields{i};
                if strcmp(f, 'index')
                    % ensure remains uint8
                    s.index = kwave.toolbox.Materials.ensureUint8Index(s.index, 'index');
                    continue;
                end
                v = s.(f);
                if isnumeric(v) && isscalar(v)
                    % Preserve NaN but cast to single
                    s.(f) = single(v);
                end
            end
        end
    end
end