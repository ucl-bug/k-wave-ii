%% LogLevels
% *Package:* kwave.toolbox
% *Superclasses:* int8
%
%% Description
% Enumerated type for defining log levels within the |kwave.toolbox.Logger|
% class. The log levels include |Debug|, |Info|, |Warning|, and |Error|.
% Each level is associated with a specific numeric value, allowing for
% comparisons to manage the verbosity of log messages.
%
%% Enumeration Members
% * |Debug (0)| - Messages used in debugging and development.
% * |Info (1)| - General informational messages that confirm the code is
%   operating as expected.
% * |Warning (2)| - Messages that warn of unexpected events or minor issues
%   that the code can handle.
% * |Error (3)| - Error messages detailing serious issues that prevent the
%   code from continuing.
%
%% Usage
%   % Setting a log level in the Logger class.
%   kwave.toolbox.Logger.setLogLevel(kwave.toolbox.LoggerLevels.Debug);
%
%   % Using in conditional statements.
%   currentLevel = kwave.toolbox.LoggerLevels.Info;
%   if currentLevel <= kwave.toolbox.LoggerLevels.Warning
%       disp('Log this message');
%   end
%
%% See Also
% * |kwave.toolbox.Logger|

% Copyright (C) 2024- The k-Wave Authors.
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

classdef LogLevels < int8
    enumeration
        Debug(0)
        Info(1)
        Warning(2)
        Error(3)
    end
end
