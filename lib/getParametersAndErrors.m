function [xdata, ydata, subjectNames] = getParametersAndErrors(subjects, firstExp, secondExp, firstorientation, secondorientation, parameter)

    xdata = []; ydata = []; subjectNames = [];
    
    
    for i=1:length(subjects)
        subject = subjects(i);
        subjectName = subject.name;
        
        if(strcmp(subjectName, "Aggregated"))
            continue;
        end
        
        xId = strcat(firstExp, '_', firstorientation, '_', ...
            parameter);
        yId = strcat(secondExp, '_', secondorientation, '_', ...
            parameter);

        
        x = subject.(xId);
        y = subject.(yId);
        
        if(isnan(x) || isnan(y))
            continue; % Skip if the subject doesn't have the parameter for both protocols
        end
        
        xPosErr = subject.(strcat(xId, '_pos_error'));
        xNegErr = subject.(strcat(xId, '_neg_error'));
        
        xErr = (abs(xPosErr) + abs(xNegErr))/2;
        
        yPosErr = subject.(strcat(yId, '_pos_error'));
        yNegErr = subject.(strcat(yId, '_neg_error'));
        
        yErr = (abs(yPosErr) + abs(yNegErr))/2;
        
        thisxData = [x, xErr];
        thisyData = [y, yErr];
        
        xdata = [xdata; thisxData];
        ydata = [ydata; thisyData];
        subjectNames = [subjectNames string(subjectName)];
        
    end

end