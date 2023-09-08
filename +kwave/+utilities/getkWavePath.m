%% getkWavePath
% *Package:* kwave.utilities
%
% Return the path to the root k-Wave folder.
%
%% Syntax
%   path = getkWavePath;
%
%% Description
% Returns the path to the root k-Wave folder.
%
%% Output Arguments
% * |path| - (string) Path to k-Wave.

function path = getkWavePath()

path = fileparts(fileparts(fileparts(mfilename('fullpath'))));
