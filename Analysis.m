clear variables; close all;
% Add helper functions to path
addpath(fullfile(pwd, 'lib')); 
% Supress directory warnings
warning('off','MATLAB:MKDIR:DirectoryExists');

% Create folders to store plots and parameter spreadsheets
mkdir(fullfile(pwd,'Parameters'));
mkdir(fullfile(pwd,'Plots'));

dataAnswer = questdlg('Select the type of analysis', ...
    'Analysis selection', 'Chi^2', 'Correlation', 'Chi^2');

if strcmp(dataAnswer,'Chi^2')
    % Create a struct to store information about each experiment
    % (experiment name, csv name, plot color) and trigger user input prompt
    % to determine which experiments to plot
    info = createInfoStruct();
    
    % Ask user whether to plot in linear or cos(theta) scale, whether to
    % run through every subject individually, and whether or not to
    % autosave plots and fit parameters
    [thetaScale, everySubject, savePlots, saveParams] = askQuestions();
    
    % If run all subjects was selected, a list of all subjects in the data
    % folder is generated and the analysis is run for every subject on the
    % list
    if everySubject
        % Get list of all subjects
        subjects = getSubjects();
        % Run analysis for each subject
        for i=1:length(subjects)
            subject = subjects(i);
            subject.saveParams = saveParams;
            subject.savePlots = savePlots;
            subject.thetaScale = thetaScale;
            
            % Main analysis logic is in this function
            analyzeSubject(subject, info);
        end
    % If run all subjects was not selected, the user is asked to specify a
    % subject and that subject's data is analyzed
    else
        % Get subject name
        subject = userInput();
        subject.saveParams = saveParams;
        subject.savePlots = savePlots;
        subject.thetaScale = thetaScale;
        
        % Main analysis logic is in this function
        analyzeSubject(subject, info);
    end
else
    correlationAnalysis();
end

