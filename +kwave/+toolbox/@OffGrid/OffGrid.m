%% OffGrid
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

classdef OffGrid < grid
    
    % Properties set by constructor.
    properties(SetAccess=immutable)
        
        % Number of dimensions.
        dimensions(1,1) double {mustBeLessThanOrEqual(dimensions,2)} = 0;   

        % Grid size [grid points].
        gridSize(1,2) double {mustBeInteger, mustBePositive, mustBeFinite} = [1, 1, 1];
        
        % Grid point spacing [m].
      	gridSpacing(1,2) double {mustBeNonnegative, mustBeFinite} = [0, 0, 0];

    end
    
    % Dependent properties without set methods. These parameters are not
    % stored but re-computed each time they are needed.
    properties(Dependent=true, GetAccess=public, SetAccess=private)
        
        % Grid size in each direction [grid points].
        Nx;
        Ny;
        
        % Grid point spacing in each direction [m].
      	dx;
        dy;

        % 1D vector of grid coordinates [m].
        xVec;
        yVec; 
        
        % Nx by Ny by Nz matrix containing repeated copies of the grid
        % coordinates [m].
        Gridx;
        Gridy;
        Gridz;
        
        % Total number of grid points.
        totalGridPoints;

    end
    
    % Constructor.
    methods
        function obj = OffGrid(kGrid, gridSize, gridSpacing, kGridLocations)
            
            arguments
                kGrid Grid
                gridSize(1,2) double {mustBeInteger, mustBePositive, mustBeFinite}
                gridSpacing(1,2) double {mustBeNonnegative, mustBeFinite}
                kGridLocations double {mustBeFinite}
            end

            % Set grid dimensions based on length of gridSize vector.
            obj.dimensions = numel(gridSize);

            obj.kGrid = kGrid; 
            % Insert Check that the dimension is reduced from Grid
                % if 3D grid offGrid must be at most 2D
                % if 2D grid offGrid must be at most 1D
                % if 1D grid, offGrid can be 1D but is a collection of
                %   disjoined points

            % Assign gridSize and gridSpacing.
            obj.gridSize(1:obj.dimensions) = gridSize;
            if (numel(gridSpacing) ~= 1) && (numel(gridSpacing) ~= obj.dimensions)
                kwave.toolbox.Logger.error('Grid:incorrectInputSize', 'gridSpacing must be a scalar or the same length as gridSize.');
            end
            obj.gridSpacing(1:obj.dimensions) = gridSpacing;

            obj.kGridLocations = kGridLocations;
            % Insert Check for kGridLocations being within the grid, both
            %   in dimension and in the physical space.
            % Should be given as a gridsize matrix, of kgrid vector
            %   co-ordinates, how to store efficently...

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


        function dx = get.dx(obj)
            dx = obj.gridSpacing(1);
        end

        function dy = get.dy(obj)
            dy = obj.gridSpacing(2);
        end


        % 1D vector of grid coordinates.
        function xVec = get.xVec(obj)
            xVec = ((1:obj.Nx).' - ceil((obj.Nx + 1)/2)) .* obj.dx;
        end

        function yVec = get.yVec(obj)
            yVec = ((1:obj.Ny).' - ceil((obj.Ny + 1)/2)) .* obj.dy;
        end

        % Nx by Ny by Nz matrix containing repeated copies of the grid
        % coordinates.
        % UPDATE THESE
        function x = get.Gridx(obj)
            switch obj.dimensions
                case 1
                    x = obj.xVec;
                case 2
                    x = repmat(obj.xVec, [1, obj.Ny]);
                case 3
                    x = repmat(obj.xVec, [1, obj.Ny, obj.Nz]);
            end
        end

        function y = get.Gridy(obj)
            switch obj.dimensions
                case 1
                    y = 0;
                case 2
                    y = repmat(obj.yVec.', [obj.Nx, 1]);
                case 3
                    y = repmat(obj.yVec.', [obj.Nx, 1, obj.Nz]);
            end
        end

        function z = get.Gridz(obj)
            switch obj.dimensions
                case 1
                    z = 0;
                case 2
                    z = 0;
                case 3
                    z = repmat(permute(obj.zVec, [2 3 1]), [obj.Nx, obj.Ny, 1]);
            end
        end
                
        % Total number of grid points.
        function N = get.totalGridPoints(obj)
            N = prod(obj.gridSize);
        end
  
    end
end
