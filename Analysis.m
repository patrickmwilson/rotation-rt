clear variables; close all;

% Add helper functions to path
addpath(fullfile(pwd, 'lib')); 

% Supress directory warnings
warning('off','MATLAB:MKDIR:DirectoryExists');

mkdir(fullfile(pwd,'Parameters'));
mkdir(fullfile(pwd,'Plots'));


dataAnswer = questdlg('Select the type of analysis', ...
    'Analysis selection', 'Chi^2', 'Significance Testing', 'Chi^2');

if strcmp(dataAnswer,'Chi^2')
    
    info = struct('name', NaN, 'csvName', NaN, 'color', NaN);

    info = repmat(info, 1, 3);

    info(1).name = 'Pitch';
    info(1).csvName = 'Face Pitch Rotation RT';
    info(1).color = [0 0.8 0.8];

    info(2).name = 'Yaw';
    info(2).csvName = 'Face Yaw Rotation RT';
    info(2).color = [0.86 0.27 0.07];

    info(3).name = 'Roll';
    info(3).csvName = 'Face Roll Rotation RT';
    info(3).color = [1 0.6 0];

    global CHECKBOXES;
    ButtonUI(info);

    info(1).include = CHECKBOXES(1);
    info(2).include = CHECKBOXES(2);
    info(3).include = CHECKBOXES(3);

    dataAnswer = questdlg('Linear scale or 1-cos(theta)', ...
            'Data Selection', 'Linear', 'cos(theta)', 'Cancel', 'Linear');
    if strcmp(dataAnswer,'Cancel')
        return;
    end
    thetaScale = ~strcmp(dataAnswer, 'Linear');
    
    dataAnswer = questdlg('Run every subject (long)?', ...
        'Data Selection', 'Yes', 'No', 'Cancel', 'Yes');
    if strcmp(dataAnswer,'Cancel')
        return;
    end
    
    everySubject = strcmp(dataAnswer, 'Yes');
    
    % Input dialogue: save plots?
    dataAnswer = questdlg('Save plots?', 'Plot Output', 'Yes', 'No', 'Cancel', ...
        'Yes');
    savePlots = strcmp(dataAnswer, 'Yes');
    if strcmp(dataAnswer, 'Cancel')
        return;
    end

    % Input dialogue: save parameters?
    dataAnswer = questdlg('Save parameters to csv?', 'Parameter Output', 'Yes', ...
        'No', 'Cancel', 'Yes');
    saveParams = strcmp(dataAnswer, 'Yes');
    if strcmp(dataAnswer, 'Cancel')
        return;
    end
    
    if everySubject
        subjects = getSubjects();
        for i=1:length(subjects)
            subject = subjects(i);
            subject.saveParams = saveParams;
            subject.savePlots = savePlots;
            subject.thetaScale = thetaScale;
            analyzeSubject(subject, info);
        end
    else
        subject = userInput();
        subject.saveParams = saveParams;
        subject.savePlots = savePlots;
        subject.thetaScale = thetaScale;
        
        analyzeSubject(subject, info);
    end
    
else
end

