% printFitParameters.m
%
% Prints the fit parameters calculated via Chi^2 minimization to a central
% spreadsheet. Takes a subject struct and the paramOutput struct as input
% arguments. Prints to a different spreadsheet depending upon whether
% linear or 1-Cos(theta) scale was selected.
%
function printFitParameters(subject, paramOutput)

    % Generate filepath for fit parameter spreadsheet
    if subject.thetaScale
        fileName = fullfile(pwd, 'Parameters', ...
            'theta_scale_fit_parameters.csv');
    else
        fileName = fullfile(pwd, 'Parameters', 'fit_parameters.csv');
    end
        
    % Convert fit parameter struct to table for output
    paramOutput = struct2table(paramOutput);

    if(exist(fileName, 'file') ~= 2) % If file does not exist, print column names
        writetable(paramOutput,fileName,'WriteRowNames',true);
    else
        writetable(paramOutput,fileName,'WriteRowNames',false, ...
            'WriteMode', 'Append');
    end
end