function subject = userInput()
    subject = struct('name', NaN, 'savePlots', NaN, 'saveParams', NaN);

    % Input dialogue: average all data of the given type?
    dataAnswer = questdlg('Combine all subjects?', 'Data Selection', 'Yes', ...
        'No', 'Cancel', 'Yes');

    if strcmp(char(dataAnswer(1)),'C')
        return;
    elseif strcmp(char(dataAnswer(1)),'Y')
        subject.name = "All";
    else
        % Input dialogue: subject name
        subject.name = string(inputdlg({'Subject name (all caps, underscores for spaces)'}, ...
            'Session Info', [1 70], {''}));
    end
    
end