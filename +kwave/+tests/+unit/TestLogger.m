%% TestLogger
% *Package:* kwave.tests.unit
% *Superclasses:* matlab.unittest.TestCase
%
% Unit tests for the kwave.toolbox.Logger class.

classdef TestLogger < matlab.unittest.TestCase
    
    properties
        logFileName = 'testLogFile.txt';
    end
    
    methods (TestClassSetup)

        % Create an empty log file.
        function createLogFile(testCase)
            kwave.toolbox.Logger.reset;
            fclose(fopen(testCase.logFileName, 'w'));
        end

    end
    
    methods (TestClassTeardown)

        % Delete the log file.
        function deleteLogFile(testCase)
            kwave.toolbox.Logger.reset;
            delete(testCase.logFileName);
        end     

    end
    
    methods (Test)
        
        % Smoke test for the debug log method.
        function testLoggerDebugMethod(~)
            kwave.toolbox.Logger.debug('Debug message.');
        end
        
        % Smoke test for the info log method.
        function testLoggerInfoMethod(~)
            kwave.toolbox.Logger.info('Information message.');
        end
        
        % Smoke test for the warning log method.
        function testLoggerWarningMethod(~)
            kwave.toolbox.Logger.warning('Warning message.');
        end
        
        % Test the error log method.
        function testLoggerErrorMethod(testCase)
            testCase.verifyError(@() kwave.toolbox.Logger.error('TestClass:CustomErrorID', 'Error message.'), 'TestClass:CustomErrorID');
        end

        % Test setting the output to a file and verify the line addition.
        function testSetLogToFile(testCase)
            kwave.toolbox.Logger.setLogToFile(testCase.logFileName);
            message = 'Message written to a file.';
            kwave.toolbox.Logger.info(message);
            
            fileContent = fileread(testCase.logFileName);
            testCase.verifyNotEmpty(strfind(fileContent, message));
        end        

        % Test setting the log level and verify the line is not added.
        function testSetLogLevel(testCase)
            kwave.toolbox.Logger.setLogLevel(kwave.toolbox.LogLevels.Warning);
            kwave.toolbox.Logger.setLogToFile(testCase.logFileName);
            message = 'This message should not appear.';
            kwave.toolbox.Logger.debug(message);
            
            fileContent = fileread(testCase.logFileName);
            testCase.verifyEmpty(strfind(fileContent, message));
        end

        % Test showing the time stamp and verify 'Info' is in the file,
        % which is added as part of the time stamp.
        function testShowTimeStamp(testCase)
            kwave.toolbox.Logger.setLogLevel(kwave.toolbox.LogLevels.Info);
            kwave.toolbox.Logger.showTimeStamp(true);
            message = 'This message should appear with a time stamp.';
            kwave.toolbox.Logger.info(message);

            fileContent = fileread(testCase.logFileName);
            testCase.verifyNotEmpty(strfind(fileContent, 'Info'));
        end

        % Smoke test setting log output back to the command line.
        function testSetLogToCommandLine(~)
            kwave.toolbox.Logger.setLogToCommandLine();
            kwave.toolbox.Logger.info('Message written to command line.');
        end
        
    end
    
end
