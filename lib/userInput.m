% userInput.m
%
% Input prompts allowing the user to specify the subject to analyze.
% Returns a subject struct with fields subject name, bool saveplots, and
% bool saveparams. These are set in a later function.
%
function subject = userInput()
    subject = struct('name', NaN, 'savePlots', NaN, 'saveParams', NaN);

    % Input dialogue: Aggregate all data for the given experiment?
    dataAnswer = questdlg('Combine all subjects?', 'Data Selection', 'Yes', ...
        'No', 'Cancel', 'Yes');
    if strcmp(char(dataAnswer(1)),'C')
        error("Script terminated by user");
    elseif strcmp(char(dataAnswer(1)),'Y')
        subject.name = "Aggregated";
    else
        % Input dialogue: Subject name
        subject.name = string(inputdlg({'Subject name (all caps, underscores for spaces)'}, ...
            'Session Info', [1 70], {''}));
    end
    
end