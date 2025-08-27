%% GenerateDocumentation
% *Package:* kwave.utilities
%
% Generate help documentation.
%
%% Syntax
%   kwave.utilities.GenerateDocumentation
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
        helpDirHtml;
        helpDirMd;
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
            addpath(obj.rootPath);
            obj.helpDirHtml = fullfile(obj.rootPath, 'helpfiles');
            obj.helpDirMd = fullfile(obj.rootPath, 'helpfilesweb');
            obj.createHelpDir;

            % Generate HTML files.
            obj.generateHTML('/+kwave/+docfiles/+general');
            initialValueProblemsFilenames = obj.generateHTML('/+kwave/+tutorials/+initialvalueproblems', evalCode=true, showCode=true);
            toolboxFilenames = obj.generateHTML('/+kwave/+toolbox');
            testFilenames = obj.generateHTML('/+kwave/+tests');
            utilityFilenames = obj.generateHTML('/+kwave/+utilities');
            developerFilenames = obj.generateHTML('/+kwave/+docfiles/+developer', showCode=true);

            % Build helptoc.
            obj.helpTocStart;
            obj.helpTocAddSection(initialValueProblemsFilenames, 'Initial Value Problems');
            obj.helpTocAddSection(toolboxFilenames, 'Toolbox Functions');
            obj.helpTocAddSection(testFilenames, 'Test Functions');
            obj.helpTocAddSection(utilityFilenames, 'Utility Functions');
            obj.helpTocAddSection(developerFilenames, 'Developer Documentation');
            obj.helpTocFinish;

            % Build searchable docs.
            disp('Generating search database...');
            builddocsearchdb(obj.helpDirHtml);

        end
    end

    methods(Access=private, Hidden=true)

        % Create empty helpfiles directory.
        function createHelpDir(obj)
            if exist(obj.helpDirHtml, 'file')
                rmdir(obj.helpDirHtml, 's');
            end
            mkdir(obj.helpDirHtml);
            if exist(obj.helpDirMd, 'file')
                rmdir(obj.helpDirMd, 's');
            end
            mkdir(obj.helpDirMd);
        end

        % Convert m-files in specified directory to HTML using publish.
        function mFilenames = generateHTML(obj, relativeFolder, options)
            arguments
                obj
                relativeFolder
                options.showCode = false;
                options.evalCode = false;
            end

            % Get namespace from folder
            nameSpace = obj.folderToNamespace(relativeFolder);

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
            [mFilenames(:).title] = deal('');
            [mFilenames(:).htmlFileName] = deal('');
            [mFilenames(:).mdFileName] = deal('');

            % Loop over m-files.
            for ind = 1:numFiles

                % Get filename without extension.
                [~, filename, ~] = fileparts(mFilenames(ind).name);

                % Get relative folder (may be empty if in root folder).
                mFileRelativeFolder = erase(mFilenames(ind).folder, absolutePath);
                mFileRelativeFolder = erase(mFileRelativeFolder, filesep);

                % We need to treat class methods that are in separate files
                % slightly differently, as these can only be compiled if we
                % change directories. To do this, check if the m-file is in
                % a class folder AND has a different name to the class.
                % Otherwise, we need to prepend the namespace to the
                % filename. If there is a nested namespace, this also needs
                % prepending.
                if obj.isClass(mFileRelativeFolder, filename)
                    mFilenames(ind).isClass = true;
                end

                bareFilename = filename;
                if obj.isClassMethod(mFileRelativeFolder, filename)
                    mFilenames(ind).isClassMethod = true;
                    mFilenames(ind).className = [mFileRelativeFolder(2:end) '.m']; % Convert folder name to class name by removing the leading "@" character.
                    cd(mFilenames(ind).folder);
                    filename = [filename '.m']; %#ok<AGROW>
                else
                    % Not a class or class method
                    filename = [nameSpace filename]; %#ok<AGROW>
                end

                % Print details of conversions.
                disp(['Converting ', filename, ' to HTML (', int2str(ind), '/', int2str(numFiles), ')']);

                % Extract title used for entry in helptoc.xml from first
                % line of code documentation.
                mFilenames(ind).title = kwave.utilities.parseTitle(fullfile(mFilenames(ind).folder, mFilenames(ind).name));

                % Publish to html.
                htmlFile = publish(filename, ...
                    'format', 'html', ...
                    'outputDir', obj.helpDirHtml, ...
                    'evalCode', options.evalCode, ...
                    'showCode', options.showCode);

                % Publish to md.
                inputFunctionFullFileName = fullfile(mFilenames(ind).folder, mFilenames(ind).name);
                % Create full paths for .mlx (matlab live script) and .md (markdown) files.
                fullFileNameMLX  = fullfile(obj.helpDirMd, [bareFilename '.mlx']);
                fullFileNameMD   = fullfile(obj.helpDirMd, [bareFilename '.md']);
                % Print details of conversion from .m to .md
                disp(['Converting ', filename, ' to ' [bareFilename '.md']]);
                % Converts the .m file into a .mlx file and saves it.
                matlab.internal.liveeditor.openAndSave(inputFunctionFullFileName, fullFileNameMLX);
                % Exports the .mlx file into a .md file.
                export(fullFileNameMLX, fullFileNameMD, Format="markdown", HideCode=true);
                % Deletes the intermediate .mlx file
                delete(fullFileNameMLX);


                % Rename to include classname if a class method.
                [~, filename, ext] = fileparts(htmlFile);
                %disp([htmlFile, ' ', fullFileNameMD, ' ', bareFilename]); % full name, full name, bare name
                if mFilenames(ind).isClassMethod
                    [~, className, ~] = fileparts(mFilenames(ind).className);
                    filename = [className '-' filename];
                    newHtmlFile = fullfile(obj.helpDirHtml, [filename '.html']);
                    movefile(htmlFile, newHtmlFile);
                    newMdFile = fullfile(obj.helpDirMd, [filename '.md']);
                    movefile(fullFileNameMD, newMdFile);
                end
                mFilenames(ind).htmlFileName = [filename, ext];
                mFilenames(ind).mdFileName = [filename, '.md'];
                %disp([mFilenames(ind).htmlFileName, ' ', mFilenames(ind).mdFileName]); % file only name

                % Change back to root directory.
                cd(obj.rootPath);

            end

            % Add relative links to class methods from class documentation.
            for ind1 = 1:numFiles
                for ind2 = 1:numFiles
                    if mFilenames(ind1).isClass && mFilenames(ind2).isClassMethod && strcmp(mFilenames(ind2).className, mFilenames(ind1).name)

                        disp(['Replacing html links to method ', mFilenames(ind2).name, ' from class ', mFilenames(ind1).name]);
                        [~, methodName, ~] = fileparts(mFilenames(ind2).name);
                        htmlFileName = mFilenames(ind1).htmlFileName;
                        htmlFile = fullfile(obj.helpDirHtml, htmlFileName);

                        % Read in HTML file.
                        fid = fopen(htmlFile, 'r');
                        fileContents = fread(fid, '*char');
                        fclose(fid);

                        % Replace links, and save to HTML file replacing
                        % contents. The |methodName| syntax is published as
                        % <tt>methodName</tt>. The html flags are included
                        % in the search to avoid adding links to code
                        % snippets.
                        fileContents = strrep(fileContents.', ...
                            ['<tt>' methodName '</tt>'], ...
                            ['<tt>' obj.generateLink(mFilenames(ind2).htmlFileName, methodName) '</tt>']);
                        fid = fopen(htmlFile, 'w');
                        fprintf(fid, '%s', fileContents.');
                        fclose(fid);

                        disp(['Replacing md links to method ', mFilenames(ind2).name, ' from class ', mFilenames(ind1).name]);
                        mdFileName = mFilenames(ind1).mdFileName;
                        mdFile = fullfile(obj.helpDirMd, mdFileName);

                        % Read in md file.
                        fid = fopen(mdFile, 'r');
                        fileContents = fread(fid, '*char');
                        fclose(fid);

                        % Add links, and save to md file. The |methodName| 
                        % syntax is published as `methodName`. The quotes are included
                        % in the search to avoid adding links to code snippets.
                        fileContents = strrep(fileContents.', ...
                            ['`' methodName '`'], ...
                            ['[' methodName '](' mFilenames(ind2).mdFileName ')']);
                        fid = fopen(mdFile, 'w');
                        fprintf(fid, '%s', fileContents.');
                        fclose(fid);
                    end
                end
            end
        end

        % Given a directory (e.g. '/+kwave/+utils'), convert to the
        % corresponding namespace (e.g. 'kwave.utils')
        function nameSpace = folderToNamespace(~, folder)

            nameSpace = replace(folder, '/+', '.');

            % Strip any leading .
            if strcmp(nameSpace(1), '.')
                nameSpace = nameSpace(2:end);
            end

            % Add a trailing .
            if ~isempty(nameSpace)
                nameSpace = [nameSpace, '.'];
            end

        end

        % Given a folder (e.g. '@Grid') and a filename (e.g.
        % 'Grid.m'), return true if the file represents the class
        % itself (as opposed to a class method)
        function isClass = isClass(~, mFileRelativeFolder, filename)
            isClass = ~isempty(mFileRelativeFolder) && strcmp(extractAfter(mFileRelativeFolder, 1), filename);
        end

        % Given a folder (e.g. '@Grid') and a filename (e.g.
        % 'validateSize.m'), return true if the file represents a class
        % method
        function isClassMethod = isClassMethod(obj, mFileRelativeFolder, filename)
            isClassMethod = ~isempty(mFileRelativeFolder) && ~obj.isClass(mFileRelativeFolder, filename);
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
                    obj.addToXML(['<tocitem target="' mFilenames(ind).htmlFileName '">' mFilenames(ind).title '</tocitem>']);
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
            filename = fullfile(obj.helpDirHtml, 'helptoc.xml');
            writelines(line, filename, 'WriteMode','append');
        end

        % Convenience function to generate HTML link to file.
        %
        % htmlFilename should include the .html file extension
        function link = generateLink(~, htmlFilename, methodName)
            link = ['<a href="' htmlFilename '">' methodName '</a>'];
        end

    end

end
