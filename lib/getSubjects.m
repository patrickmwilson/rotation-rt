% getSubjects.m
%
% Returns a struct of the names of all the individual subject folders within
% the data folder, effectively a list of all the subjects. Adds
% 'Aggregated' as the first subject.
%
function subjects = getSubjects()
    % Aggregated data first so that it is in the first row of the fit
    % parameter output spreadsheet
    subjects = struct('name', 'Aggregated');
    
    % Get a list of all subfolders within Data folder
    folders = dir(fullfile(pwd, 'Data'));
    folderNames={folders(:).name}';
    
    % Loop through the folders and add valid folders to subjects struct
    for j=1:size(folderNames,1)
        folderName = string(folderNames{j,1});

        if(startsWith(folderName,"."))
            continue; % Skips folders such as .DS_STORE
        end
        subjects(end+1) = struct('name', folderName);
    end

end