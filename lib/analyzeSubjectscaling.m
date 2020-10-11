function analyzeSubject(subject)
    
    infoStructFile = fullfile(pwd, 'lib', 'struct_templates', 'protocol_info');
    paramStructFile = fullfile(pwd, 'lib', 'struct_templates', 'params');
    
    info = table2struct(readtable(infoStructFile));
    
    for i=1:length(info)
        if ~info(i).include
            continue;
        end
        
        data = readCsv(info(i).name, subject.name);
        
        if isempty(data)
            continue;
        end
        
        disp(data);
        disp('------------------------');
        
        logPlot = figure();
        smChiSqPlot = figure();
        lgChiSqPlot = figure();
        
        paramOutput = table2struct(readtable(paramStructFile));
        
        paramOutput.Subject = subject.name; 
        
        [paramOutput, incorrectPercentages, rtAverages, logylim] = analyzeData(data, ...
            info(i), subject, paramOutput, logPlot, ...
            smChiSqPlot, lgChiSqPlot);
        
        
        formatFigure(logPlot, ...
            [log10(0.5) log10(64)], ...
            logylim, ...
            "Stimulus Height (log10(°))", ...
            "Reaction Time (ms)", ...
            strcat("Reaction Time vs. Stimulus Height (", string(info(i).type), ")"), ...
            false, 'best');
        
        figure(logPlot);
        xticks(unique(log10(data(:,1))));
        xticklabels({'1', '2', '4', '8', '16', '32'});
        

        if subject.savePlots
            % If data was averaged, save the plots to Plots/Averaged/<type> 
            % otherwise in Plots/<type>/<subjectName>
            if(strcmp(subject.name,'All'))
                folderName = fullfile(pwd, 'Plots', 'Averaged');
            else
                folderName = fullfile(pwd, 'Plots', string(subject.name));
            end
            
            mkdir(folderName);
            
            figs = [logPlot, smChiSqPlot, lgChiSqPlot];
            figNames = [" semilog", " sm chisq", ...
                " lg chisq"];

            for j=1:length(figs)
                fileName = sprintf('%s%s%s%s', string(subject.name), ...
                    '_', info(i).id, figNames(j));
                saveas(figs(j), fullfile(folderName, ...
                    strcat(fileName, '.png')));
                saveas(figs(j), fullfile(folderName, ...
                    strcat(fileName, '.tif')));
            end
        end

        for j=1:length(figs)
            close(figs(j));
        end
        
        if subject.saveParams
            csvname = strcat(string(info(i).filestarter), ...
                '_Fit_Parameters.csv');
            
            fileName = fullfile(pwd, 'Parameters', csvname);
            
            paramOutput = struct2table(paramOutput);
            
            if(exist(fileName, 'file') ~= 2) % If file does not exist, print header
                writetable(paramOutput,fileName,'WriteRowNames',true);
            else
                writetable(paramOutput,fileName,'WriteRowNames',false, ...
                    'WriteMode', 'Append');
            end
            
            csvname = strcat(string(info(i).filestarter), ...
                '_RT_Averages.csv');
            
            fileName = fullfile(pwd, 'Parameters', csvname);
            
            if(exist(fileName, 'file') ~= 2) % If file does not exist, print header
                writetable(rtAverages,fileName,'WriteRowNames',true);
            else
                writetable(rtAverages,fileName,'WriteRowNames',false, ...
                    'WriteMode', 'Append')
            end
            
            csvname = strcat(string(info(i).filestarter), ...
                '_Incorrect_Percentages.csv');
            
            fileName = fullfile(pwd, 'Parameters', csvname);
            
            if(exist(fileName, 'file') ~= 2) % If file does not exist, print header
                writetable(incorrectPercentages, fileName, ...
                    'WriteRowNames',true);
            else
                writetable(incorrectPercentages, fileName, ...
                    'WriteRowNames',false, 'WriteMode', 'Append')
            end
        end
    end
end