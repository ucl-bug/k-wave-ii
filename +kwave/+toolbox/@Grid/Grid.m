%% Grid
% *Package:* kwave.toolbox
%
% Class used to define the spatial grid for a simulation.
%
%% Syntax
%   kgrid = Grid(gridSize, gridSpacing)
%   kgrid = Grid(gridSize, gridSpacing, gridPadding)
%
%% Description
% |Grid| is the grid class used across the k-Wave Toolbox. An object
% of the |Grid| class defines the grid coordinates and spatial
% frequency (wavevector) matrices for a particular simulation.
% 
% The grid is assumed to be a regular Cartesian grid with grid spacing
% given by |gridSpacing|. The spatial grid matrices are indexed as: (x, 1)
% in 1D; (x, y) in 2D; and (x, y, z) in 3D. Typically the grid spacing in
% each direction is constant where |gridSpacing| is defined by a scalar.
%
% To create the object, pass the |gridSize| in grid points and the
% |gridSpacing| in metres. For example, to create a 2D grid that is 128 x
% 128 with a grid spacing of 1 mm, call:
%
%     kgrid = Grid([128, 128], 1e-3);
%
% The origin is defined to be in the centre of the spatial grid. For odd
% dimensions, the origin is at the central point. For even dimensions, the
% origin is shifted one grid point in the positive direction. For example,
% in the x-direction, the origin when |kgrid.Nx| is even is at
% |kgrid.xVec(end/2 + 1)|.
%
% The wavevector components are defined with the zero frequency at the
% centre of the spectrum. These should be transformed using |ifftshift|
% before using with the MATLAB FFT functions (which are based on FFTW).
%
% Optionally, the |gridPadding| can be specified in grid points. This
% defines an additional padding on the outside of the grid defined by
% |gridSize|. The padding is added to each side of the grid in each
% Cartesian direction, so the total grid size including padding will be
% |gridSize + 2*gridPadding|. Note, the grid and wavevector properties are
% defined relative to |gridSize|, not including the |gridPadding|.
%
% To check if an input matrix matches the grid size specified by a
% |Grid| object, the |validateSize| method can be used.
%
%% Input Arguments
% * |gridSize| - (double) Number of grid points in each Cartesian direction
%   [grid points].
% * |gridSpacing| - (double) Grid point spacing [m]. Can be specified as a
%   scalar value, or the spacing in each Cartesian direction. Be careful if
%   specifying different spacings in each direction, as the maximum
%   supported frequency depends on the grid spacing.
% * |gridPadding| - (double) Grid padding [grid points]. Can be specified
%   as a scalar value, or the padding in each Cartesian direction. If not
%   specified, the padding is set to [0, 0, 0].
%
%% Properties
% Properties which can be queried, but not modified, after the object is
% created.
%
% * |dimensions| - (double) Number of grid dimensions (1, 2, or 3).
% * |gridSize| - (double) Number of grid points in each direction defined
%   as a 3-element row vector [gridPoints]. For 1D and 2D grids, the higher
%   dimensions have a size of 1.
% * |gridSpacing| - (double) Grid point spacing in each direction defined
%   as a 3-element row vector [m]. For 1D and 2D grids, the higher
%   dimensions have a spacing of 0.
% * |gridPadding| - (double) Grid padding in each direction defined
%   as a 3-element row vector [gridPoints]. For 1D and 2D grids, the higher
%   dimensions have a padding of 0.
% * |Nx|, |Ny|, |Nz| - (double) Individual components of |gridSize|.
% * |dx|, |dy|, |dz| - (double) Individual components of |gridSpacing|.
% * |xVec|, |yVec|, |zVec| - (double) Grid coordinates in each direction
%   [m].
% * |x|, |y|, |z| - (double) Nx by Ny by Nz matrices containing repeated
%   copies of the grid coordinates [m].
% * |xSize|, |ySize|, |zSize| - (double) Physical size of grid [m].
% * |totalGridPoints| - (double) Total number of grid points.
% * |kxVec|, |kyVec|, |kzVec| - (double) Wavevector components in each
%   direction [rad/m].
% * |kx|, |ky|, |kz| - (double) Nx by Ny by Nz matrices containing repeated
%   copies of the wavevector components [rad/m].
% * |k| - (double) Nx by Ny by Nz matrix of scalar wavenumber [rad/m].
% * |kxMax|, |kyMax|, |kzMax| - (double) Maximum supported spatial
%   frequency in each direction [rad/m].
% * |kMax| - (double) Maximum supported spatial frequency in all directions
%   [rad/m]. If the grid spacing is different in each direction, |kMax| is
%   given as the maximum spatial frequency that is supported in all
%   directions, i.e., the minimum of [kxMax, kyMax, kzMax].
%
%% Methods
% * |assignWithGridPadding|
% * |displayGridSize|
% * |highestPrimeFactors|
% * |returnWithoutGridPadding|
% * |validateSize|

classdef Grid < handle
    
    % Properties set by constructor.
    properties(SetAccess=immutable)
        
        % Number of dimensions.
        dimensions(1,1) double {mustBeLessThanOrEqual(dimensions,3)} = 0;   

        % Grid size [grid points].
        gridSize(1,3) double {mustBeInteger, mustBePositive, mustBeFinite} = [1, 1, 1];
        
        % Grid point spacing [m].
      	gridSpacing(1,3) double {mustBeNonnegative, mustBeFinite} = [0, 0, 0];

        % Grid padding size [grid points].
        gridPadding(1,3) double {mustBeInteger, mustBeNonnegative, mustBeFinite} = [0, 0, 0];

    end
    
    % Dependent properties without set methods. These parameters are not
    % stored but re-computed each time they are needed.
    properties(Dependent=true, GetAccess=public, SetAccess=private)
        
        % Grid size in each direction [grid points].
        Nx;
        Ny;
        Nz;
        
        % Grid point spacing in each direction [m].
      	dx;
        dy;
        dz;

        % 1D vector of grid coordinates [m].
        xVec;
        yVec;
        zVec;    
        
        % Nx by Ny by Nz matrix containing repeated copies of the grid
        % coordinates [m].
        x;
        y;
        z;
        
        % Physical size of grid [m].
        xSize;
        ySize;
        zSize;
        
        % Total number of grid points.
        totalGridPoints;

        % 1D vector of wavevector components [rad/m].
        kxVec;
        kyVec;
        kzVec;

        % Nx by Ny by Nz matrix containing repeated copies of wavevector
        % components [rad/m].
        kx;
        ky;
        kz;

        % Maximum supported spatial frequency in each direction [rad/m].
        kxMax;
        kyMax;
        kzMax;
        
        % Nx by Ny by Nz matrix of scalar wavenumber [rad/m].
        k;

        % Maximum supported spatial frequency in all directions [rad/m].
        kMax;

    end
    
    % Constructor.
    methods
        function obj = Grid(gridSize, gridSpacing, gridPadding)
            
            % Set grid dimensions based on length of gridSize vector.
            obj.dimensions = numel(gridSize);

            % Assign gridSize and gridSpacing.
            obj.gridSize(1:obj.dimensions) = gridSize;
            if (numel(gridSpacing) ~= 1) && (numel(gridSpacing) ~= obj.dimensions)
                kwave.toolbox.Logger.error('Grid:incorrectInputSize', 'gridSpacing must be a scalar or the same length as gridSize.');
            end
            obj.gridSpacing(1:obj.dimensions) = gridSpacing;

            % Assign gridPadding.
            if nargin == 3
                if (numel(gridPadding) ~= 1) && (numel(gridPadding) ~= obj.dimensions)
                    kwave.toolbox.Logger.error('Grid:incorrectInputSize', 'gridSpacing must be a scalar or the same length as gridSize.');
                end
                obj.gridPadding(1:obj.dimensions) = gridPadding;
            end

        end
    end
    
    % Get methods for dependent properties.
    methods
        
        % Grid size and spacing in each direction.
        function Nx = get.Nx(obj)
            Nx = obj.gridSize(1);
        end

        function Ny = get.Ny(obj)
            Ny = obj.gridSize(2);
        end

        function Nz = get.Nz(obj)
            Nz = obj.gridSize(3);
        end

        function dx = get.dx(obj)
            dx = obj.gridSpacing(1);
        end

        function dy = get.dy(obj)
            dy = obj.gridSpacing(2);
        end

        function dz = get.dz(obj)
            dz = obj.gridSpacing(3);
        end

        % 1D vector of grid coordinates.
        function xVec = get.xVec(obj)
            xVec = ((1:obj.Nx).' - ceil((obj.Nx + 1)/2)) .* obj.dx;
        end

        function yVec = get.yVec(obj)
            yVec = ((1:obj.Ny).' - ceil((obj.Ny + 1)/2)) .* obj.dy;
        end

        function zVec = get.zVec(obj)
            zVec = ((1:obj.Nz).' - ceil((obj.Nz + 1)/2)) .* obj.dz;
        end

        % Nx by Ny by Nz matrix containing repeated copies of the grid
        % coordinates.
        function x = get.x(obj)
            switch obj.dimensions
                case 1
                    x = obj.xVec;
                case 2
                    x = repmat(obj.xVec, [1, obj.Ny]);
                case 3
                    x = repmat(obj.xVec, [1, obj.Ny, obj.Nz]);
            end
        end

        function y = get.y(obj)
            switch obj.dimensions
                case 1
                    y = 0;
                case 2
                    y = repmat(obj.yVec.', [obj.Nx, 1]);
                case 3
                    y = repmat(obj.yVec.', [obj.Nx, 1, obj.Nz]);
            end
        end

        function z = get.z(obj)
            switch obj.dimensions
                case 1
                    z = 0;
                case 2
                    z = 0;
                case 3
                    z = repmat(permute(obj.zVec, [2 3 1]), [obj.Nx, obj.Ny, 1]);
            end
        end

        % Physical size of grid.
        function xSize = get.xSize(obj)
            xSize = obj.Nx .* obj.dx;
        end

        function ySize = get.ySize(obj)
            ySize = obj.Ny .* obj.dy;
        end

        function zSize = get.zSize(obj)
            zSize = obj.Nz .* obj.dz;
        end
                
        % Total number of grid points.
        function N = get.totalGridPoints(obj)
            N = prod(obj.gridSize);
        end

        % 1D vector of wavevector components.
        function kxVec = get.kxVec(obj)
            kxVec = obj.getWavenumbers(obj.Nx, obj.dx);
        end

        function kyVec = get.kyVec(obj)
            kyVec = obj.getWavenumbers(obj.Ny, obj.dy);
        end

        function kzVec = get.kzVec(obj)
            kzVec = obj.getWavenumbers(obj.Nz, obj.dz);
        end

        % Nx by Ny by Nz matrix of scalar wavenumber.
        function k = get.k(obj)
            switch obj.dimensions
                case 1
                    k = abs(obj.kxVec);
                case 2
                    k = zeros(obj.gridSize);
                    k = k + reshape(obj.kxVec, [], 1, 1).^2;
                    k = k + reshape(obj.kyVec, 1, [], 1).^2;
                    k = sqrt(k);
                case 3
                    k = zeros(obj.gridSize);
                    k = k + reshape(obj.kxVec, [], 1, 1).^2;
                    k = k + reshape(obj.kyVec, 1, [], 1).^2;
                    k = k + reshape(obj.kzVec, 1, 1, []).^2;
                    k = sqrt(k);
            end
        end

        % Nx by Ny by Nz matrix containing repeated copies of wavevector
        % components [rad/m].
        function kx = get.kx(obj)
            switch obj.dimensions
                case 1
                    kx = obj.kxVec;
                case 2
                    kx = repmat(obj.kxVec, [1, obj.Ny]);
                case 3
                    kx = repmat(obj.kxVec, [1, obj.Ny, obj.Nz]);
            end
        end

        function ky = get.ky(obj)
            switch obj.dimensions
                case 1
                    ky = 0;
                case 2
                    ky = repmat(obj.kyVec.', [obj.Nx, 1]);
                case 3
                    ky = repmat(obj.kyVec.', [obj.Nx, 1, obj.Nz]);
            end
        end   

        function kz = get.kz(obj)
            switch obj.dimensions
                case 1
                    kz = 0;
                case 2
                    kz = 0;
                case 3
                    kz = repmat(permute(obj.kzVec, [2 3 1]), [obj.Nx, obj.Ny, 1]);
            end
        end
  
        % Maximum supported frequency.
        function kxMax = get.kxMax(obj)
            kxMax = max(abs(obj.kxVec(:)));
        end

        function kyMax = get.kyMax(obj)
            kyMax = max(abs(obj.kyVec(:)));
        end

        function kzMax = get.kzMax(obj)
            kzMax = max(abs(obj.kzVec(:)));
        end

        function kMax = get.kMax(obj)
            kMaxVec = [obj.kxMax, obj.kyMax, obj.kzMax];
            kMaxVec(kMaxVec == 0) = [];
            kMax = min(kMaxVec);
        end
        
    end
       
    % General class methods.
    methods
        highestPrimeFactors = highestPrimeFactors(obj);
        displayGridSize(obj);
        validateSize(obj, matrix, options);
        matrix = assignWithGridPadding(obj, matrix, edgeValues);
        matrix = returnWithoutGridPadding(obj, matrix);
    end
    
    % Methods that can only be accessed by class members.
    methods (Access='protected', Static=true, Hidden=true) 
        kVec = getWavenumbers(Nx, dx)
    end
end
