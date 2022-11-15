%% kWaveAcousticMedium
% *Package:* kwave.toolbox
% *Superclasses:* kwave.toolbox.kWaveInput
%
% Class used to define the acoustic medium properties for a simulation.
%
%% Syntax
%   medium = kWaveAcousticMedium(kgrid);
%
%% Description
% This class is used to define the acoustic medium properties. The
% constructor takes an object of the |kWaveGrid| class which defines the
% grid size. All medium properties can be scalar or have the same size as
% the grid with the exception of |alphaPower| and |soundSpeedReference|,
% which must be scalar. The |soundSpeed| and |density| must be defined.
%
% Note: Internally, the medium properties that are allowed to be
% heterogeneous are stored including the grid padding defined by
% |kgrid.gridPadding|. The set and get methods automatically add and remove
% the grid padding. The padded variants can be accessed via the hidden
% properties |densityPadded|, etc.
%
%% Examples
% Define the grid and medium objects, and assign the sound speed and
% density.
%
%    kgrid = kwave.toolbox.kWaveGrid([128, 128], 1e-3);
%    medium = kwave.toolbox.kWaveAcousticMedium(kgrid);
%    medium.soundSpeed = rand(medium.gridSize);
%    medium.density = rand(medium.gridSize);
%
%% Properties
% * |soundSpeed| - (single) Compressional sound speed [m/s].
% * |soundSpeedReference| - (single) Reference Compressional sound speed
%   used in the k-space correction [m/s]. 
% * |density| - (single) Mass density [kg/m^2].
% * |alphaCoeff| - (single) Power law attenuation coefficient
%   [dB/(MHz^y cm)]. 
% * |alphaPower| - (single) Power law attenuation power.
% * |BonA| - (single) Parameter of nonlinearity.
%
%% See Also
% * |kWaveInput|

classdef kWaveAcousticMedium < kwave.toolbox.kWaveInput

    properties
        soundSpeedReference single
        alphaPower single
    end

    properties(Hidden=true)
        soundSpeedPadded single
        densityPadded single
        alphaCoeffPadded single
        BonAPadded single
    end

    properties(Dependent=true)
        soundSpeed single
        density single
        alphaCoeff single
        BonA single
    end

    properties(Constant, Hidden=true)
        requiredProperties = {'soundSpeed', 'density'};
    end

    % Set and get methods.
    methods
        
        function set.soundSpeed(obj, val)
            obj.kgrid.validateSize(val, VariableName='soundSpeed');
            obj.soundSpeedPadded = obj.kgrid.assignWithGridPadding(val);
        end

        function set.soundSpeedPadded(obj, val)
            obj.kgrid.validateSize(val, VariableName='soundSpeedPadded', IncludePadding=true);
            obj.soundSpeedPadded = val;
        end

        function soundSpeed = get.soundSpeed(obj)
            soundSpeed = obj.kgrid.returnWithoutGridPadding(obj.soundSpeedPadded);
        end

        function set.soundSpeedReference(obj, val)
            validateattributes(val, {'numeric'}, {'numel', 1}, '', 'soundSpeedReference');
            obj.soundSpeedReference = val;
        end

        function set.density(obj, val)
            obj.kgrid.validateSize(val, VariableName='density');
            obj.densityPadded = obj.kgrid.assignWithGridPadding(val);
        end

        function set.densityPadded(obj, val)
            obj.kgrid.validateSize(val, VariableName='densityPadded', IncludePadding=true);
            obj.densityPadded = val;
        end

        function density = get.density(obj)
            density = obj.kgrid.returnWithoutGridPadding(obj.densityPadded);
        end

        function set.alphaCoeff(obj, val)
            obj.kgrid.validateSize(val, VariableName='alphaCoeff');
            obj.alphaCoeffPadded = obj.kgrid.assignWithGridPadding(val);
        end

        function set.alphaCoeffPadded(obj, val)
            obj.kgrid.validateSize(val, VariableName='alphaCoeffPadded', IncludePadding=true);
            obj.alphaCoeffPadded = val;
        end

        function alphaCoeff = get.alphaCoeff(obj)
            alphaCoeff = obj.kgrid.returnWithoutGridPadding(obj.alphaCoeffPadded);
        end          

        function set.alphaPower(obj, val)
            validateattributes(val, {'numeric'}, {'numel', 1}, '', 'alphaPower');
            obj.alphaPower = obj.kgrid.assignWithGridPadding(val);
        end

        function set.BonA(obj, val)
            obj.kgrid.validateSize(val, VariableName='BonA');
            obj.BonAPadded = obj.kgrid.assignWithGridPadding(val);
        end

        function set.BonAPadded(obj, val)
            obj.kgrid.validateSize(val, VariableName='BonAPadded', IncludePadding=true);
            obj.BonAPadded = val;
        end        

        function BonA = get.BonA(obj)
            BonA = obj.kgrid.returnWithoutGridPadding(obj.BonAPadded);
        end

    end

end
