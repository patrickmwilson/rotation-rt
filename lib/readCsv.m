% readCSV
%
% Extracts data from csv files. Normalizes the eccentricity values by
% retinal eccentricity and recursively removes outliers greater than +/-
% 2.5 sigma from the mean of the normalized distribution. Accepts the
% csvName, csvId, data type, subject name, and a boolean indicating whether
% to remove small eccentricity values from crowded center as input
% arguments. Returns the raw data, truncated data, and any outliers.
function [data, incorrect] = readCsv(experimentName,subjectName)
    
    % Suppress warning about modified csv headers
    warning('off','MATLAB:table:ModifiedAndSavedVarnames');
    
    % Creates filepaths to all the subfolders within each base folder
    folderPaths = [];

    baseFolder = string(fullfile(pwd, 'Data'));

    folders = dir(baseFolder);
    folderNames={folders(:).name}';
    for j=1:size(folderNames,1)
        folderName = string(folderNames{j,1});

        if(startsWith(folderName,"."))
            continue; % Skips folders such as .DS_STORE
        end

        % If a subject was specified, skip any folders which do not
        % match the subject code
        if(~strcmp(subjectName,'All'))
            if(~strcmp(subjectName,folderName))
                continue;
            end
        end

        % Create the new file path and append it to the array
        folderPath = string(fullfile(baseFolder, folderName));
        folderPaths = [folderPaths folderPath];  
    end

    data = []; 
    incorrect = [];
    for i=1:length(folderPaths)
        folder = folderPaths(i);
        
        % Get the names of all the csv files within the folder
        files = dir(folder);
        fileNames={files(:).name}';
        csvFiles=fileNames(endsWith(fileNames,'.csv'));
        
        % Loop over every csv file, extracting data from files which match
        % the search conditions
        for j=1:size(csvFiles,1)
            file = char(csvFiles{j,1});
            
            % csv file names follow this convention:
            % SUBJECT_DATE_PROTOCOLNAME.csv
            underscores = find(file == '_'); % Find indices of underscores
            period = find(file == '.'); % Find the period

            % Extract the portion of the csv file name between the last
            % underscore and the period
            protocolName = string(extractBetween(file, (underscores(end)+1), (period-1)));
            if(~strcmp(protocolName, experimentName))
                continue; % Skip csv files from other protocols
            end
            
            thisData = [];
            thisIncorrect = [];
            
            % Extract the data from the csv into an array
            filename = fullfile(folder, string(csvFiles(j,1)));
            raw = table2array(readtable(filename));
        
            % Creates a 3 column matrix of the data. Stimulus height is
            % placed in
            % -------------------------------------------------------------------!!!!!!!!!!
            % col 1, reaction time in col 2, correct/incorrect in col 3
            thisData(:,1) = raw(:,2);
            thisData(:,2) = raw(:,3);
            thisData(:,3) = raw(:,4);
            thisData(:,4) = raw(:,1);
            
            k = 1;
            while k <= length(thisData)
                if thisData(k, 4) == 0
                    thisIncorrect = [thisIncorrect; thisData(k,:)];
                    thisData(k,:) = [];
                else
                    k = k + 1;
                end
            end
            
            % Concatenate these values with accumulated values
            [thisData, ~] = cleanAndRemoveOutliers(thisData);
            data = [data; thisData];
            incorrect = [incorrect; thisIncorrect];
        end
    end
end