% readCSV.m
%
% Extracts data from csv files located within the Data folder. Given a
% subject and experiment name, it will search for the matching .csv file
% within the subject's subfolder. Alternatively, if the subject name given
% is 'Aggregated', it will combine data from all subjects. 
%
% Returns correct responses in the data matrix, incorrect responses in
% the incorrect matrix. Removes outliers from the data matrix. See
% cleanAndRemoveOutliers.m for more information.
%
function [data, incorrect, withOutliers] = readCsv(experimentName,subjectName)
    
    % Suppress warning about modified csv headers
    warning('off','MATLAB:table:ModifiedAndSavedVarnames');
    
    % Creates filepaths to all the subfolders within each base folder
    folderPaths = [];
    
    % All data is located within this folder
    baseFolder = string(fullfile(pwd, 'Data'));
    
    % Get a list of all the subfolders within the data folder. Each subject
    % has an individual folder in this directory that contains all of their
    % data.
    folders = dir(baseFolder);
    folderNames={folders(:).name}';
    
    % Loop through all the subject folders
    for j=1:size(folderNames,1)
        folderName = string(folderNames{j,1});

        if(startsWith(folderName,"."))
            continue; % Skips folders such as .DS_STORE
        end

        % If a subject was specified, skip any folders which do not
        % match the subject code. If Aggregated was specified, do not skip
        % any subject folders
        if(~strcmp(subjectName,'Aggregated'))
            if(~strcmp(subjectName,folderName))
                continue;
            end
        end

        % Create a filepath to the current folder if it matches the search
        % criteria and add it to the array of folder paths
        folderPath = string(fullfile(baseFolder, folderName));
        folderPaths = [folderPaths folderPath];  
    end
    
    % Initialize empty matrices for the data (correct responses, outliers 
    % removed), correct responses with outliers (used later to calculate 
    % response accuracy percentages), and incorrect responses
    data = []; withOutliers = []; incorrect = [];
    
    % Loop through each of the folders that were found to match the search
    % criteria (subject name)
    for i=1:length(folderPaths)
        folder = folderPaths(i);
        
        % Get the names of all the csv files within the folder
        files = dir(folder);
        fileNames={files(:).name}';
        csvFiles=fileNames(endsWith(fileNames,'.csv'));
        
        % Loop over every csv file, extracting data from files which match
        % the search conditions (experiment name)
        for j=1:size(csvFiles,1)
            file = char(csvFiles{j,1});
            
            % csv file names follow this convention:
            % SUBJECT_DATE_PROTOCOLNAME.csv
            underscores = find(file == '_'); % Find indices of underscores
            period = find(file == '.'); % Find the period

            % Extract the portion of the csv file name between the last
            % underscore and the period (experiment name)
            protocolName = string(extractBetween(file, (underscores(end)+1), (period-1)));
            if(~strcmp(protocolName, experimentName))
                continue; % Skip csv files from other protocols
            end
            
            % Initialize empty matrices to store the data from the csv file
            % currently being read
            thisData = []; thisIncorrect = [];
            
            % Extract the data from the csv into an array
            filename = fullfile(folder, string(csvFiles(j,1)));
            raw = table2array(readtable(filename));
        
            % Creates a 4 column matrix of the data. Column 1 contains face
            % rotation in degrees, column 2 contains reaction time in ms,
            % column 3 contains a 1 if the target face was shown, or a zero
            % if the distractor face was shown. Column 4 contains a 1 if
            % the subject responded correctly, 0 otherwise.
            thisData(:,1) = raw(:,2);
            thisData(:,2) = raw(:,3);
            thisData(:,3) = raw(:,4);
            thisData(:,4) = raw(:,1);
            
            % Loop through the raw data matrix and remove rows 
            % corresponding to incorrect responses (0 in column 4). Copy
            % these rows into a separate matrix for incorrect responses.
            k = 1;
            while k <= length(thisData)
                if thisData(k, 4) == 0
                    thisIncorrect = [thisIncorrect; thisData(k,:)];
                    thisData(k,:) = [];
                else
                    k = k + 1;
                end
            end
            
            % Concatenate data with existing withOutliers matrix and
            % incorrect matrix
            withOutliers = [withOutliers; thisData];
            incorrect = [incorrect; thisIncorrect];
            
            % Remove outliers from the data and concatenate with existing
            % matrix
            [thisData, ~] = cleanAndRemoveOutliers(thisData);
            data = [data; thisData];
        end
    end
end