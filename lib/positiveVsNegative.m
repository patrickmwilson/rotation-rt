function positiveVsNegative(subjects, info, folderName, graphNames, scale)

    paramTypes = ["slope", "intercept"];
    
    for i=1:length(info)
        exp = info(i).name;
        
        for k=1:length(paramTypes)
            paramType = paramTypes(k);

            [xdata, ydata, subjectNames] = getParametersAndErrors(...
                subjects, exp, exp, 'neg', 'pos', paramType);

            fig = figure();

            [slope, intercept, R, reduced_chi_sq] = assessCorrelation(...
                xdata, ydata);

            graphCorrelation(xdata, ydata, slope, intercept, R, ...
                reduced_chi_sq, subjectNames, graphNames, fig);

            figure(fig);
            figName = sprintf("%s Negative %s vs. %s Positive %s (%s)", exp, paramType, exp, paramType, scale);
            title(figName);
            xlabel(sprintf("%s Positive %s", exp, paramType));
            ylabel(sprintf("%s Negative %s", exp, paramType));

            saveas(fig, fullfile(folderName, strcat(figName, '.png')));
            close(fig);
        end
        
    end
end