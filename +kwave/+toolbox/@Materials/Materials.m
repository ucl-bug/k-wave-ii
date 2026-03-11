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
        REQUIRED_FIELDS = {'soundSpeed','density'};
        OPTIONAL_FIELDS = {
            'index', ...
            'absorptionCoeff',...
            'absorptionPower',...
            'BonA', ...
            'specificHeat',...
            'thermalConductivity'};

        FIELD_VALIDATORS = struct( ...
            'soundSpeed',          @kwave.toolbox.Materials.validateNonNegScalar, ...
            'density',             @kwave.toolbox.Materials.validateNonNegScalar, ...
            'absorptionCoeff',     @kwave.toolbox.Materials.validateNonNegScalar, ...
            'absorptionPower',     @kwave.toolbox.Materials.validateNonNegScalar, ...
            'BonA',                @kwave.toolbox.Materials.validateNonNegScalar, ...
            'specificHeat',        @kwave.toolbox.Materials.validateNonNegScalar, ...
            'thermalConductivity', @kwave.toolbox.Materials.validateNonNegScalar, ...
            'index',               @kwave.toolbox.Materials.validateIndexField ...
            );

        RESERVED_PROPS = {'REQUIRED_FIELDS','OPTIONAL_FIELDS','FIELD_VALIDATORS','RESERVED_PROPS'};
    end


    % Methods for validating Materials fields attributes
    methods (Static, Access = private)

        function out = validateNonNegScalar(value, fieldName)
            try
                mustBeNumeric(value);
                mustBeReal(value);
                mustBeFinite(value);
                mustBeNonnegative(value);
            catch
                error('Materials:NotNonNegativeScalar', ...
                    ['Field "%s" must be a non-negative real scalar.', fieldName]);
            end

            % Enforce single
            out = single(value);

        end

        function out = validateIndexField(value, fieldName)
            if ~(isnumeric(value) && isscalar(value) && ...
                    value >= 0 && value <= 255 && value == floor(value))
                error('Materials:InvalidIndexField',...
                    ['Field "%s" must be an integer scalar in the range [0, 255].', fieldName]);
            end

            % Enforce uint8 type
            out = uint8(value);
        end

    end

    methods

        function obj = Materials()

            % Pre-populate with two examples (types are enforced on add).
            water = struct( ...
                'index',               0, ... % uint8 limits the number of materials to 256
                'soundSpeed',          1480, ...     % m/s @ ~20°C
                'density',             1000, ...     % kg/m^3
                'absorptionCoeff',     0.5, ...      % dB/cm/MHz^y
                'absorptionPower',     2, ...        % (y) dimensionless
                'BonA',                5, ...        % dimensionless
                'specificHeat',        4181, ...     % J/(kg·K)
                'thermalConductivity', 0.58 );       % W/(m·K)
            obj.addMaterial('water', water);

            air = struct( ...
                'index',               1, ...
                'soundSpeed',          343, ...
                'density',             1.225, ...
                'BonA',                0.7, ...
                'specificHeat',        1005, ...
                'thermalConductivity', 0.026 );
            obj.addMaterial('air', air);

        end

        function assignedIdx = addMaterial(obj, name, data)
            % ADDMATERIAL  Add a new material to the Materials object.
            % assignedIdx = addMaterial(obj, name, data) adds a new material with the
            % given name and structure. If the structure does not contain an 'index'
            % field, the next available index in [0,255] is assigned. Returns the
            % assigned index value.

            % Validate that 'name' is a string-like scalar
            if ~( (ischar(name) && isrow(name)) || (isstring(name) && isscalar(name)) )
                error('Materials:InvalidNameType', ...
                    'Material name must be a char row vector or a string scalar.');
            end

            % Normalize to char for addprop
            name = char(name);

            % Check material name is not reserved
            if ismember(name, obj.RESERVED_PROPS)
                error('Materials:ReservedName', ...
                    '"%s" is a reserved property name and cannot be used.', name);
            end

            % Check the name does not already exist on this object
            if isprop(obj, name)
                error('Materials:NameExists', ...
                    'A material or property named "%s" already exists.', name);
            end

            % Check required fields
            for f = obj.REQUIRED_FIELDS
                if ~isfield(data, f{1})
                    error('Materials:MissingField', ...
                        'Material "%s" is missing required field "%s".', name, f{1});
                end
            end

            % Check for unknown fields
            allowed = [obj.REQUIRED_FIELDS, obj.OPTIONAL_FIELDS];
            dataFields = fieldnames(data);
            for f = dataFields'
                if ~ismember(f{1}, allowed)
                    error('Materials:UnknownField', ...
                        'Unknown field "%s" in material "%s".', f{1}, name);
                end
            end

            % Collect existing indices
            materialNames = properties(obj);
            usedIdx = [];
            for m = materialNames'
                matStruct = obj.(m{1});
                if isstruct(matStruct) && isfield(matStruct, "index")
                    usedIdx(end+1) = double(matStruct.index); %#ok<AGROW>
                end
            end

            % Handle index: validate if provided, else allocate
            if isfield(data, "index")
                % Validate/normalize the provided index first (to uint8, in-range, integer)
                data.index = obj.FIELD_VALIDATORS.index(data.index, 'index');

                % Check for collision
                if ismember(double(data.index), usedIdx)
                    error('Materials:IndexInUse', ...
                        'Index %d is already used by another material.', double(data.index));
                end

                assignedIdx = data.index;  % already uint8
            else
                % Find smallest unused index in [0,255]
                candidateIdx = 0;
                while ismember(candidateIdx, usedIdx)
                    candidateIdx = candidateIdx + 1;
                    if candidateIdx > 255
                        error('Materials:NoIndicesLeft', ...
                            'No available indices left in range [0,255].');
                    end
                end

                data.index = uint8(candidateIdx);
                assignedIdx = data.index;
            end

            % Validate and convert each field 
            dataFields = fieldnames(data);
            for f = dataFields'
                fname = f{1};
                if isfield(obj.FIELD_VALIDATORS, fname)
                    data.(fname) = obj.FIELD_VALIDATORS.(fname)(data.(fname), fname);
                end
            end

            % Add dynamic property and store the struct
            obj.addprop(name);
            obj.(name) = data;

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
                        data(i, j) = single(s.(f));
                    end
                end
            end

            varNames = [{'Name','Index'}, orderedFields];
            T = table( string(names(:)), double(idxCol(:)), ...
                data(:,1), data(:,2), data(:,3), data(:,4), data(:,5), data(:,6), data(:,7), ...
                'VariableNames', varNames);

            % plain‑text output if no output is assigned
            % this is done to avoid tables breaking the documentation generation (see #233 for context)
            if nargout == 0
                fprintf('%s\n', evalc('disp(T)'));
                clear T  
            end
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
end