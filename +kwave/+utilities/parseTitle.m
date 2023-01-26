%% parseTitle
% *Package:* kwave.utilities
%
% Convenience function to extract the text appearing on the first
% line of an m-file after the characters "%% ".
function titleString = parseTitle(filename)
    fid = fopen(filename);
    titleLine = fgetl(fid);
    if any(strfind(titleLine, "%% "))
        titleString = erase(titleLine, "%% ");
    else
        error('GenerateDocumentation:missingTitleComment', '%s is missing a title comment.', filename);
    end
    fclose(fid);
end
