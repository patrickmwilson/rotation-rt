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
            analyzeSubject(subject);
        end
    else
        subject = userInput();
        subject.saveParams = saveParams;
        subject.savePlots = savePlots;
        
        analyzeSubject(subject);
    end
    
else
    infoStructFile = fullfile(pwd, 'lib', ...
        'struct_templates', 'protocol_info');
    info = table2struct(readtable(infoStructFile));
    
    for i=1:length(info)
        disp(info(i).name);
        rmAnovaTest(info(i));
        disp('---------------------------');
    end
end




