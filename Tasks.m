% Tasks: OffGrid(kgrid,[dxii,dxij],[Nxii,Nxij])
% dim = kgrid.dim-1
% PointLocs(xii,yij) in (x,y) parametrisation of surface.

% OffGridBndry(OffGrid)
% b(x,xi) (Nx x Ny x Nz) x ( Nxii x Nxij ) matrix
% invA matrix(Nxii x Nxij) x (Nxii x Nxij) inverted
% D(x,xi) distance matrix between grids
    % Been doing these in OffGrid
    

% AcousticOffGridBndry
% p0(xi) values of boundary condition
% BndrySource = kgrid object