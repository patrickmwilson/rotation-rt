% askQuestions.m
%
% Ask user whether to plot in linear or cos(theta) scale, whether to
% run through every subject individually, and whether or not to
% autosave plots and fit parameters
%
function [thetaScale, everySubject, savePlots, saveParams] = askQuestions()
    
    % Input dialogue: Linear or 1-Cos(theta) scale?
    dataAnswer = questdlg('Linear scale or 1-Cos(theta)', ...
        'Data Selection', 'Linear', '1-Cos(theta)', 'Cancel', 'Linear');
    if strcmp(dataAnswer,'Cancel')
        error("Script terminated by user");
    end
    thetaScale = ~strcmp(dataAnswer, 'Linear');
    
    % Input dialogue: Run every subject individually?
    dataAnswer = questdlg('Run every subject individually (long)?', ...
        'Data Selection', 'Yes', 'No', 'Cancel', 'Yes');
    if strcmp(dataAnswer,'Cancel')
        error("Script terminated by user");
    end
    everySubject = strcmp(dataAnswer, 'Yes');
    
    % Input dialogue: Save plots?
    dataAnswer = questdlg('Save plots?', 'Plot Output', 'Yes', 'No', 'Cancel', ...
        'Yes');
    savePlots = strcmp(dataAnswer, 'Yes');
    if strcmp(dataAnswer, 'Cancel')
        error("Script terminated by user");
    end

    % Input dialogue: Save parameters?
    dataAnswer = questdlg('Save parameters to csv?', 'Parameter Output', 'Yes', ...
        'No', 'Cancel', 'Yes');
    saveParams = strcmp(dataAnswer, 'Yes');
    if strcmp(dataAnswer, 'Cancel')
        error("Script terminated by user");
    end
    
end