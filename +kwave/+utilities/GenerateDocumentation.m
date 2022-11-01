%% kWaveGrid
% *Package:* kwave.utilities
%
% Generate help documentation.
%
%% Syntax
%   GenerateDocumentation.
%
%% Description
% |GenerateDocumentation| is a static class that is called to generate the
% help files that appear in the MATLAB help browser. The documentation is
% generated in several stages: 
%
% # The .m files in specified directories are converted directly to .html
%   using the MATLAB <matlab:doc('publish') publish> function. Text should
%   be written using MATLAB publishing markup, which is parsed as headings,
%   code, etc.
% # The generated .html files are modified to add html links between
%   related functions and classes.
% # A helptoc.xml file is automatically created, adding links to the
%   generated .html files.
% # The documentation search database is created using
%   <matlab:doc('builddocsearchdb') builddocsearchdb>.
% 
% This class is provided for generating documentation during development,
% and for preparing the documentation packaged with a release. If you have
% downloaded a packaged release, there should be no need to call this
% class. However, if you have directly cloned the repository and are
% working with bleeding-edge changes, you can call |GenerateDocumentation|
% to (re-)generate the help files.

classdef GenerateDocumentation

    properties(SetAccess=immutable, Hidden=true)
        helpDir;
        rootPath;
    end

    % Constructor.
    methods(Static)
        function obj = GenerateDocumentation()

            % Setup paths. The toolbox root directory is two levels above
            % +kwave/+utilities. Add back forward slash to directory if on
            % linux or mac.
            [mFilePath, ~, ~] = fileparts(mfilename('fullpath'));
            mFilePathParts = split(mFilePath, filesep);
            obj.rootPath = fullfile(mFilePathParts{1:end-2});
            if isunix
                obj.rootPath = [filesep obj.rootPath];
            end
            obj.helpDir = fullfile(obj.rootPath, 'helpfiles');
            obj.createHelpDir;

            % Generate HTML files.
            obj.generateHTML('/+kwave/+docfiles', 'kwave.docfiles.');
            initialValueProblemsFilenames = obj.generateHTML('/+kwave/+tutorials/+initialvalueproblems', 'kwave.tutorials.initialvalueproblems.', evalCode=true, showCode=true);
            toolboxFilenames = obj.generateHTML('/+kwave/+toolbox', 'kwave.toolbox.');
            testFilenames = obj.generateHTML('/+kwave/+tests', 'kwave.tests.');
            utilityFilenames = obj.generateHTML('/+kwave/+utilities', 'kwave.utilities.');

            % Build helptoc.
            obj.helpTocStart;
            obj.helpTocAddSection(initialValueProblemsFilenames, 'Initial Value Problems');
            obj.helpTocAddSection(toolboxFilenames, 'Toolbox Functions');
            obj.helpTocAddSection(testFilenames, 'Test Functions');
            obj.helpTocAddSection(utilityFilenames, 'Utility Functions');
            obj.helpTocFinish;

            % Build searchable docs.
            disp('Generating search database...');
            builddocsearchdb(obj.helpDir)

        end
    end

    methods(Access=private, Hidden=true)

        % Create empty helpfiles directory.
        function createHelpDir(obj)
            if exist(obj.helpDir, 'file')
                rmdir(obj.helpDir, 's');
            end
            mkdir(obj.helpDir);
        end

        % Convert m-files in specified directory to HTML using publish.
        function mFilenames = generateHTML(obj, relativeFolder, nameSpace, options)
            arguments
                obj
                relativeFolder
                nameSpace
                options.showCode = false;
                options.evalCode = false;
            end

            % Find all m-files contained in relativeFolder and
            % sub-directories.
            disp(['Generating HTML for ' relativeFolder '...']);
            absolutePath = fullfile(obj.rootPath, relativeFolder);
            mFilenames = dir(fullfile(absolutePath, '**/*.m'));
            numFiles = length(mFilenames);

            % Initialise additional properties that we will set.
            [mFilenames(:).isClassMethod] = deal(false);
            [mFilenames(:).isClass] = deal(false);
            [mFilenames(:).className] = deal('');
            
            % Loop over m-files. 
            for ind = 1:numFiles
            
                % Get filename without extension.
                [~, filename, ~] = fileparts(mFilenames(ind).name);

                % Get relative folder (may be empty if in root folder).
                mFileRelativeFolder = erase(mFilenames(ind).folder, [absolutePath, filesep]);
            
                % We need to treat class methods that are in separate files
                % slightly differently, as these can only be compiled if we
                % change directories. To do this, check if the m-file is in
                % a class folder AND has a different name to the class.
                % Otherwise, we need to prepend the namespace to the
                % filename. If there is a nested namespace, this also needs
                % prepending.
                if (strcmp(extractAfter(mFileRelativeFolder, 1), filename))
                    mFilenames(ind).isClass = true;
                end
                if (strncmp(mFileRelativeFolder, "@", 1)) && (~mFilenames(ind).isClass)
                    mFilenames(ind).isClassMethod = true;
                    mFilenames(ind).className = [mFileRelativeFolder(2:end) '.m']; % Convert folder name to class name.
                    cd(mFilenames(ind).folder);
                    filename = [filename '.m']; %#ok<AGROW>
                elseif (strncmp(mFileRelativeFolder, "+", 1))
                    filename = [nameSpace extractAfter(mFileRelativeFolder, 1) '.' filename]; %#ok<AGROW> 
                else
                    filename = [nameSpace filename]; %#ok<AGROW> 
                end
            
                % Publish.
                disp(['Converting ', filename, ' to HTML (', int2str(ind), '/', int2str(numFiles), ')']);
                publishedFile = publish(filename, ...
                    'format', 'html', ...
                    'outputDir', obj.helpDir, ...
                    'evalCode', options.evalCode, ...
                    'showCode', options.showCode);

                % Rename to include classname if a class method.
                if ~isempty(mFilenames(ind).className)
                    [~, htmlFilename, ~] = fileparts(publishedFile);
                    [~, className, ~] = fileparts(mFilenames(ind).className);
                    movefile(publishedFile, fullfile(obj.helpDir, [className '-' htmlFilename '.html']));
                end
            
                % Change back to root directory.
                cd(obj.rootPath);
            
            end
            
            % Add relative links to class methods from class documentation.
            for ind1 = 1:numFiles
                for ind2 = 1:numFiles
                    if mFilenames(ind1).isClass && mFilenames(ind2).isClassMethod && strcmp(mFilenames(ind2).className, mFilenames(ind1).name)
            
                        disp(['Replacing links to method ', mFilenames(ind2).name, ' from class ', mFilenames(ind1).name]);
                        [~, className, ~] = fileparts(mFilenames(ind1).name);
                        [~, methodName, ~] = fileparts(mFilenames(ind2).name);
                        htmlFilename = fullfile(obj.helpDir, [className '.html']);
            
                        % Read in HTML file.
                        fid = fopen(htmlFilename, 'r');
                        fileContents = fread(fid, '*char');
                        fclose(fid);
            
                        % Replace links, and save to HTML file replacing
                        % contents. The |methodName| syntax is published as
                        % <tt>methodName</tt>. The html flags are included
                        % in the search to avoid adding links to code
                        % snippets.
                        fileContents = strrep(fileContents.', ...
                            ['<tt>' methodName '</tt>'], ...
                            ['<tt>' obj.generateLink([className '-' methodName], methodName) '</tt>']);
                        fid = fopen(htmlFilename, 'w');
                        fprintf(fid, '%s', fileContents.');
                        fclose(fid);
            
                    end
                end
            end
        end

        % Start generation of helptoc.xml.
        function helpTocStart(obj)
            disp('Generating helptoc.xml...');
            obj.addToXML('<?xml version=''1.0'' encoding="utf-8"?>');
            obj.addToXML('<toc version="2.0">');
            obj.addToXML('<tocitem target="kWave.html">k-Wave II');
        end
        
        % Add links to html for all functions, excluding class methods.
        function helpTocAddSection(obj, mFilenames, heading)
            obj.addToXML(['<tocitem>' heading]);
            for ind = 1:length(mFilenames)
                if ~mFilenames(ind).isClassMethod
                    [~, className, ~] = fileparts(mFilenames(ind).name);
                    obj.addToXML(['<tocitem target="' className '.html">' className '</tocitem>']);
                end
            end
            obj.addToXML('</tocitem>');
        end

        % Finish generation of helptoc.xml.
        function helpTocFinish(obj)
            obj.addToXML('</tocitem>');
            obj.addToXML('</toc>');
        end

        % Convenience function to call writelines.
        function addToXML(obj, line)
            filename = fullfile(obj.helpDir, 'helptoc.xml');
            writelines(line, filename, 'WriteMode','append');
        end
        
        % Convenience function to generate HTML link to file.
        function link = generateLink(~, htmlFilename, methodName)
            link = ['<a href="' htmlFilename '.html">' methodName '</a>'];
        end

    end

end
