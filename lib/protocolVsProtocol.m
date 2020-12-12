function protocolVsProtocol(subjects, info, folderName, graphNames, scale)

    paramTypes = ["slope", "intercept"];
    
    for i=1:length(info)
        firstExp = info(i).name;
        
        for j=1:length(info)
            
            if i == j
                continue;
            end
            secondExp = info(j).name;
            
            for k=1:length(paramTypes)
                paramType = paramTypes(k);
            
                [negxdata, negydata, negsubjectNames] = getParametersAndErrors(...
                    subjects, firstExp, secondExp, 'neg', 'neg', paramType);

                [posxdata, posydata, possubjectNames] = getParametersAndErrors(...
                    subjects, firstExp, secondExp, 'pos', 'pos', paramType);
                
                xdata = [negxdata; posxdata];
                ydata = [negydata; posydata];
                subjectNames = [negsubjectNames'; possubjectNames'];
                
                fig = figure();
                
                [slope, intercept, R, reduced_chi_sq] = assessCorrelation(...
                    xdata, ydata);
                
                graphCorrelation(xdata, ydata, slope, intercept, R, ...
                    reduced_chi_sq, subjectNames, graphNames, fig);
                
                figure(fig);
                figName = sprintf("%s %s vs. %s %s (%s)", secondExp, paramType, firstExp, paramType, scale);
                title(figName);
                xlabel(sprintf("%s %s", firstExp, paramType));
                ylabel(sprintf("%s %s", secondExp, paramType));
                
                saveas(fig, fullfile(folderName, strcat(figName, '.png')));
                close(fig);
            end
        end
    end
end