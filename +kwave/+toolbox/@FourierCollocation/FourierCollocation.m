%% FourierCollocation
% *Package:* kwave.toolbox
%
% Derivative calculation using the Fourier collocation spectral method.
%
%% Description
% Class used to calculate differential operators using the Fourier
% collocation spectral method. The class constructor takes a
% |kwave.toolbox.Grid| object which defines the discrete locations where
% the input field is defined. Calculations are always performed on the
% padded grid. Methods are provided for calculating the gradient of a
% scalar field, and the divergence of a vector field.
%
% Vector fields are stored by concatenating the Cartesian components in the
% fourth dimension. For example, in 2D, a vector field has size |(Nx, Ny,
% 1, 2)|, where |(:, :, 1, 1)| is the x-component, and |(:, :, 1, 2)| is
% the y-component. The |divergence| method acts on each vector component
% individually using |divergenceSplit|, and then sums the results. The
% calculations allow shifting to and from the staggered grid by setting the
% |Staggering| option.
%
% To include k-space dispersion correction in the derivative calculations,
% the property kappa should be defined. As this is a computational
% parameter, kappa must be defined on the padded grid, or be scalar. If
% kappa is scalar or not defined, derivative calculations use 1D FFTs,
% otherwise, ND FFTs are used.
%
%% Examples
% Calculate the gradient of a scalar field in 2D, and compare with the
% MATLAB |<matlab:doc('gradient') gradient>| function.
%
%   % Define input field.
%   [x, y] = meshgrid(-2:.2:2, -2:.2:2);
%   z = x .* exp(-x.^2 - y.^2);
%   
%   % Define input field.
%   kgrid = kwave.toolbox.Grid([40, 40], 0.2);
%   f = kgrid.x .* exp(-kgrid.x.^2 - kgrid.y.^2);
%   
%   % Compute gradient using k-Wave.
%   fourierDiffOps = kwave.toolbox.FourierCollocation(kgrid);
%   gradf = fourierDiffOps.gradient(f);
%   
%   % Compute gradient using finite differences with MATLAB gradient function.
%   [fy, fx] = gradient(f, kgrid.dx);
%   
%   % Plot.
%   figure;
%   subplot(2, 3, 1);
%   imagesc(gradf(:, :, :, 1));
%   colorbar;
%   axis image;
%   title('k-Wave \partialf/\partialx');
%   
%   subplot(2, 3, 2);
%   imagesc(fx);
%   colorbar;
%   axis image;
%   title('Finite Difference \partialf/\partialx');
%   
%   subplot(2, 3, 3);
%   imagesc(abs(gradf(:, :, :, 1) - fx));
%   colorbar;
%   axis image;
%   title('Difference');
%   
%   subplot(2, 3, 4);
%   imagesc(gradf(:, :, :, 2));
%   colorbar;
%   axis image;
%   title('k-Wave \partialf/\partialy');
%   
%   subplot(2, 3, 5);
%   imagesc(fy);
%   colorbar;
%   axis image;
%   title('Finite Difference \partialf/\partialy');
%   
%   subplot(2, 3, 6);
%   imagesc(abs(gradf(:, :, :, 2) - fy));
%   colorbar;
%   axis image;
%   title('Difference');
%
%% Input Arguments
% * |kgrid| - (kwave.toolbox.Grid) Object which defines the simulation grid
%   size.
%
%% Properties
% Input objects:
%
% * |kgrid| - (kwave.toolbox.Grid) Handle for grid object.
%
% Other properties:
%
% * |dimensions| - (double) Number of grid dimensions (1, 2, or 3).
%
%% Methods
% * |divergence|
% * |divergenceSplit|
% * |gradient|
% * |fractionalLaplacian|
% * |stagger|
% * |plotField|
% * |sinc|

% Copyright (C) 2022- University College London.
%
% This file is part of k-Wave-II (http://www.k-wave.org). k-Wave-II is free
% software: you can redistribute it and/or modify it under the terms of the
% GNU Lesser General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any
% later version.
% 
% k-Wave-II is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
% License for more details.
% 
% You should have received a copy of the GNU Lesser General Public License
% along with k-Wave-II. If not, see <http://www.gnu.org/licenses/>.

classdef FourierCollocation < handle

    % Properties set by the constructor.
    properties(SetAccess=immutable)
        dimensions
        kgrid
    end

    % Hidden properties that can be set internally or by derived classes.
    properties(SetAccess=immutable, Hidden=true)
        kgridPadded kwave.toolbox.Grid
    end

    % Internal 1D derivative operators defined with no staggering, forward
    % staggering, and backward staggering. These are computed in the
    % constructor and stored to save compute time during derivative
    % calculations.
    properties(SetAccess=immutable, GetAccess=private, Hidden=true)
        ddxNoShift single
        ddyNoShift single
        ddzNoShift single

        ddxShiftPos single
        ddyShiftPos single
        ddzShiftPos single

        ddxShiftNeg single
        ddyShiftNeg single
        ddzShiftNeg single

        xShiftPos single
        yShiftPos single
        zShiftPos single

        xShiftNeg single
        yShiftNeg single
        zShiftNeg single
    end

    % k-Space correction term.
    properties
        kappa single
    end

    % Constructor.
    methods
        function obj = FourierCollocation(kgrid)
            arguments
                kgrid(1,1) kwave.toolbox.Grid
            end

            % Assign properties.
            obj.dimensions = kgrid.dimensions;

            % Assign grid and expanded grid.
            obj.kgrid = kgrid;
            obj.kgridPadded = kwave.toolbox.Grid(kgrid.gridSize(1:kgrid.dimensions) + 2 * kgrid.gridPadding(1:kgrid.dimensions), kgrid.gridSpacing(1:kgrid.dimensions));

            % Assign derivative operators.
            obj.ddxNoShift = reshape(ifftshift(1i * obj.kgridPadded.kxVec), [], 1, 1);
            obj.ddyNoShift = reshape(ifftshift(1i * obj.kgridPadded.kyVec), 1, [], 1);
            obj.ddzNoShift = reshape(ifftshift(1i * obj.kgridPadded.kzVec), 1, 1, []);
            
            obj.ddxShiftPos = reshape(ifftshift(1i * obj.kgridPadded.kxVec .* exp( 1i.*obj.kgridPadded.kxVec * obj.kgridPadded.dx/2)), [], 1, 1);
            obj.ddyShiftPos = reshape(ifftshift(1i * obj.kgridPadded.kyVec .* exp( 1i.*obj.kgridPadded.kyVec * obj.kgridPadded.dy/2)), 1, [], 1);
            obj.ddzShiftPos = reshape(ifftshift(1i * obj.kgridPadded.kzVec .* exp( 1i.*obj.kgridPadded.kzVec * obj.kgridPadded.dz/2)), 1, 1, []);

            obj.ddxShiftNeg = reshape(ifftshift(1i * obj.kgridPadded.kxVec .* exp(-1i.*obj.kgridPadded.kxVec * obj.kgridPadded.dx/2)), [], 1, 1);
            obj.ddyShiftNeg = reshape(ifftshift(1i * obj.kgridPadded.kyVec .* exp(-1i.*obj.kgridPadded.kyVec * obj.kgridPadded.dy/2)), 1, [], 1);
            obj.ddzShiftNeg = reshape(ifftshift(1i * obj.kgridPadded.kzVec .* exp(-1i.*obj.kgridPadded.kzVec * obj.kgridPadded.dz/2)), 1, 1, []);

            obj.xShiftPos = reshape(ifftshift( exp( 1i.*obj.kgridPadded.kxVec * obj.kgridPadded.dx/2)), [], 1, 1);
            obj.yShiftPos = reshape(ifftshift( exp( 1i.*obj.kgridPadded.kyVec * obj.kgridPadded.dy/2)), 1, [], 1);
            obj.zShiftPos = reshape(ifftshift( exp( 1i.*obj.kgridPadded.kzVec * obj.kgridPadded.dz/2)), 1, 1, []);

            obj.xShiftNeg = reshape(ifftshift( exp(-1i.*obj.kgridPadded.kxVec * obj.kgridPadded.dx/2)), [], 1, 1);
            obj.yShiftNeg = reshape(ifftshift( exp(-1i.*obj.kgridPadded.kyVec * obj.kgridPadded.dy/2)), 1, [], 1);
            obj.zShiftNeg = reshape(ifftshift( exp(-1i.*obj.kgridPadded.kzVec * obj.kgridPadded.dz/2)), 1, 1, []);
        end
    end

    % Set and get methods.
    methods
        function set.kappa(obj, val)
            if numel(val) ~= 1
                obj.kgrid.validateSize(val, IncludePadding=true, VariableName='kappa'); %#ok<MCSUP>
            end
            obj.kappa = val;
        end
    end

    % General class methods with a concrete implementation.
    methods
        f = divergence(obj, f, varargin);
        f = divergenceSplit(obj, f, options);
        f= stagger(obj,f,options);
        out = gradient(obj, f, options);
        out = fracLaplacian(obj, f,y, options);
        plotField(obj, f);
    end

    % Static class methods with a concrete implementation.
    methods(Static)
        y = sinc(x);
    end

end
