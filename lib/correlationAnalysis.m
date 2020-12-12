function correlationAnalysis()

    % Input dialogue: Plot subject names?
    dataAnswer = questdlg('Add subject names?', '', 'Yes', 'No', 'Cancel', 'Yes');
    graphNames = (char(dataAnswer(1)) == 'Y');

    info = createInfoStruct();
    
    baseFolderName = fullfile(pwd, 'Plots', 'Correlation'); 
    mkdir(baseFolderName);
    
    scales = struct('scaleName', 'Linear', ...
        'paramFile', fullfile(pwd, 'Parameters', 'fit_parameters.csv'), ...
        'folderName', fullfile(baseFolderName, 'Linear'));
    scales = repmat(scales, 1, 2);
    scales(2).scaleName = 'Theta';
    scales(2).paramFile = fullfile(pwd, 'Parameters',...
        'theta_scale_fit_parameters.csv');
    scales(2).folderName = fullfile(baseFolderName, 'Theta');
    
    for i=1:length(scales)
        scale = scales(i);
        mkdir(scale.folderName);
        
        
        subjects = table2struct(readtable(scale.paramFile));
        
        positiveVsNegative(subjects, info, scale.folderName, graphNames, ...
            scale.scaleName);
        
        protocolVsProtocol(subjects, info, scale.folderName, graphNames, ...
            scale.scaleName);
        
        
    end
end