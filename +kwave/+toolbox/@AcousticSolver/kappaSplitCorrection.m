%% kappaSplitCorrection
% *Class:* kwave.toolbox.AcousticSolver
% *Package:* kwave.toolbox
%
% Calculate the temporal correction of a function in the time step
% variation
%
%% Syntax
%   fC = kappaSplitCorrection(obj, f)
%
%% Description
% Calculates the correction to the usual kspace corrected tempral
% derivative for using an varied time stepping by considering a first
% order interpolation.
% 
% The vector components of the correction are stacked in the 4th dimension 
% as with the gradient. For example, if calling gradient on a matrix of dimensions
% (10, 10), the output will be of size (10, 10, 1, 2). This is to allow
% codes to implement multi-dimensional support by always looping over the
% fourth dimension.
%
% The components are calculated using 1D FFTs, and kappa2 is applied in the 
% Fourier domain. before inverting the Fourier Transform.
% 
%
%% Input Arguments
% * |f| - (numeric) Scalar field that is to be corrected using.
%
%% Output Arguments
% * |fCorrected| - (numeric) Correction from f.


function fCorrected = kappaSplitCorrection(obj, f)

arguments
    obj
    f(:,:,:,:)
end

fCorrected = zeros([obj.kgridPadded.gridSize, obj.dimensions]);

for dim=1:obj.dimensions
    fCorrected(:, :, :,dim) = ifftn(obj.kappaSplit .* fftn(f(:,:,:,dim)), 'symmetric');
end

end