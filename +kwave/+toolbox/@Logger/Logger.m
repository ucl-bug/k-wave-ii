%% Logger
% *Package:* kwave.toolbox
% *Superclasses:* handle
%
% Manager for logging messages with different log levels.
%
%% Syntax
%   Logger.debug(message)
%   Logger.info(message)
%   Logger.warning(message)
%   Logger.error(errID, errorMessage)
%
%% Description
% The |Logger| class is designed to manage messages from k-Wave classes and
% functions. Four levels of verbosity are supported as defined by the
% |kwave.toolbox.LogLevels| class: |Debug|, |Info|, |Warning|, and |Error|.
%
% The |setLogLevel| function can be used to specify the minimum log level
% displayed. For example, calling
% |kwave.toolbox.Logger.setLogLevel(kwave.toolbox.LogLevels.Warning)| will
% suppress |Debug| and |Info| messages, and only print |Warning| and
% |Error| messages.
%
% Messages can be printed to an external file instead of the command line
% by calling |kwave.toolbox.Logger.setLogToFile("logFile.txt")|.
%
% The class implementation uses a singleton design so that the same log
% settings can be used across the k-Wave toolbox. The class methods are
% static, enabling direct access without a manual instantiation.
%
%% Examples
%   % Load toolbox and clear previous logger settings.
%   import kwave.toolbox.*
%   Logger.reset();
%
%   % Display debug and info messages. By default, only the info message
%   % appears as the log level is |LogLevels.Info|.
%   Logger.debug('This debug message will not be printed.');
%   Logger.info('This info message will be printed.');
%
%   % Adjust the log level and display another debug message. The debug
%   % message now shows up.
%   Logger.setLogLevel(LogLevels.Debug);
%   Logger.debug('Another debugging message');
%
%   % Alter the log output to a file, then log a message.
%   Logger.setLogToFile('logfile.txt');
%   Logger.info('This message will be printed to the log file.');
%
%   % Reset the log output to the command line, then print warning and
%   % error messages.
%   Logger.setLogToCommandLine();
%   Logger.warning('Warning message');
%   try
%       Logger.error('ClassName:CustomErrorID', 'Error message');
%   catch ME
%       disp(ME.message);
%   end
%
%% Properties
% * |logLevel| - (kwave.toolbox.LogLevels) Specifies the current log 
%   level. Messages beneath this level won't be logged. 
% * |logFile| - (char) Denotes the filename where log messages will be 
%   stored. If left empty, messages are logged to the command window.
%
%% Methods
% *Logging*
%
% * |debug| - Logs a debug message.
% * |info| - Logs an informational message.
% * |warning| - Logs a warning message and initiates a MATLAB warning.
% * |error| - Logs an error message and triggers a MATLAB error.
%
% *General*
%
% * |reset| - Clears the persistent variable and resets the logger.
% * |setLogLevel| - Modifies |logLevel|. Accepts |LogLevels.Debug|,
%   |LogLevels.Info|, |LogLevels.Warning|, and |LogLevels.Error|.
% * |setLogToFile| - Adjusts |logFile| to the specified input file.
% * |setLogToCommandLine| - Clears |logFile| value.
%
%% See Also
% * |<matlab:doc('warning') warning>|
% * |<matlab:doc('error') error>|
% * |kwave.toolbox.LogLevels|

classdef Logger < handle
    
    properties (Access = private)
        logLevel (1,1) kwave.toolbox.LogLevels;
        logFile char;
    end
    
    methods (Access = private)

        % Constructor.
        function obj = Logger()
            obj.logLevel = kwave.toolbox.LogLevels.Info;
            obj.logFile = '';
        end
        
        % Method to log messages with different log levels.
        function logMessage(obj, level, message)
            if level >= obj.logLevel
                timestamp = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss');
                formattedMessage = sprintf('%s - %s: %s', timestamp, char(level), message);
                if isempty(obj.logFile)
                    disp(formattedMessage);
                else
                    fileId = fopen(obj.logFile, 'a');
                    fprintf(fileId, '%s\n', formattedMessage);
                    fclose(fileId);
                end
            end
        end

    end
    
    methods (Static, Hidden=true)

        % Static method to access the singleton instance.
        function singleInstance = getInstance(reset)
            arguments
                reset logical = false;
            end
            persistent instance;
            if reset
                instance = [];
            elseif isempty(instance)
                instance = kwave.toolbox.Logger();
            end
            singleInstance = instance;
        end
        
        % Static method to log messages.
        function log(level, message)
            logger = kwave.toolbox.Logger.getInstance();
            logger.logMessage(level, message);
        end
        
    end

    methods (Static)

        % Method to reset the Logger instance.
        function reset()
            kwave.toolbox.Logger.getInstance(true);
        end  

        % Static method to set the log level.
        function setLogLevel(level)
            logger = kwave.toolbox.Logger.getInstance();
            logger.logLevel = level;
        end
        
        % Static method to set the output to a file.
        function setLogToFile(fileName)
            logger = kwave.toolbox.Logger.getInstance();
            logger.logFile = fileName;
        end
        
        % Static method to set the output to the command window.
        function setLogToCommandLine()
            logger = kwave.toolbox.Logger.getInstance();
            logger.logFile = [];
        end
        
        % Static method to log debug messages.
        function debug(message)
            kwave.toolbox.Logger.log(kwave.toolbox.LogLevels.Debug, message);
        end
        
        % Static method to log info messages.
        function info(message)
            kwave.toolbox.Logger.log(kwave.toolbox.LogLevels.Info, message);
        end
        
        % Static method to log warning messages and call warning.
        function warning(message)
            kwave.toolbox.Logger.log(kwave.toolbox.LogLevels.Warning, message);
            warning(message);
        end
        
        % Static method to log error messages and throw an exception.
        function error(errID, errorMessage)
            kwave.toolbox.Logger.log(kwave.toolbox.LogLevels.Error, errorMessage);
            builtin('error', errID, errorMessage);
        end

    end

end
