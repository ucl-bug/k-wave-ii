%% Initial value problem example
%
%% Overview
% This example demonstrates how to run a simple initial value problem using
% k-Wave II.
%
% * <matlab:edit('kwave.tutorials.initialvalueproblems.homogeneousMedium2D') Open the file in the MATLAB Editor>
% * <matlab:run('kwave.tutorials.initialvalueproblems.homogeneousMedium2D.m') Run the file in MATLAB>
%
%% Setup
% k-Wave uses package folders to separate the toolbox, examples, tests, and
% utilities into different namespaces. To use the classes and functions
% within the toolbox, the package name prefix |kwave.toolbox| must be
% included before the class or function name, for example,
% |kwave.toolbox.Grid|. To avoid needing to use the package prefix
% within a given m-file, the toolbox can be imported as shown below.

clearvars;
import kwave.toolbox.*

%% Defining the grid
% The simulation functions in k-Wave require four inputs. These define the
% properties of the computational grid, the material properties of the
% medium, the properties and locations of any acoustic sources, and the
% properties and locations of the sensor points used to record the
% evolution of the pressure and velocity fields over time.
% 
% Starting with the computational grid, the simulations are performed on a
% regular Cartesian mesh (for users with a background in finite-element
% methods, this is analogous to a structured mesh containing identical
% rectangular elements). The medium discretisation is defined using the
% |Grid| class. Both the total number of grid points |[Nx, Ny]| as
% well as the spacing between the grid points |dx| are used to compute the
% discretisation, and an object of the Grid class is returned.
%
% As the numerical techniques used in k-Wave are based heavily on the fast
% Fourier transform (FFT), the simulations will be fastest when the number
% of grid points in each direction is given by a power of two or has small
% prime factors. The prime factors for a particular grid can be computed
% using |kgrid.highestPrimeFactors|.

kgrid = Grid([128, 128], 0.1e-3);
