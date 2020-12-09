% saveFig.m
%
% Saves a given figure in .png format to Plots/SubjectName directory. Saves
% the figure in .tif format within Plots/SubjectName/TIF directory. 
%
function saveFig(fig, subject, experimentName, figName, folderName)
    
    % File name format: SubjectName_ExperimentName_FigureName
%     fileName = sprintf('%s%s%s%s%s', string(subject.name), '_', ...
%         string(experimentName), '_', figName);
    fileName = sprintf('%s_%s_%s_Plot', string(subject.name), ...
        string(experimentName), figName);
    
    saveas(fig, fullfile(folderName, strcat(fileName, '.png')));
    saveas(fig, fullfile(folderName, 'TIF', strcat(fileName, '.tif')));
    
end