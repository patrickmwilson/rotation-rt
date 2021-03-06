% analyzeSubject.m
%
% Contains the main analysis logic. Takes subject and info structs as input
% arguments. Reads in data for selected experiments and performs Chi^2
% minimization and plotting. 
% 
% Produces several plots: combined linear plot
% with all protocols graphed on it, individual linear plots for each
% protocol, graphs of Chi^2 vs. slope and intercept parameters for both
% negative and positive rotations, and a plot of response accuracy vs.
% rotation for each protocol. Saves these plots as .png and .tif, and
% outputs the fit parameters to a spreadsheet.
%
function analyzeSubject(subject, info)
    
    % Create struct to store fit parameters for output
    fileName = fullfile(pwd,'lib','struct_templates', ...
            'param_struct.csv');
    paramOutput = table2struct(readtable(fileName));
    paramOutput.name = subject.name;
    
    % Making folderpath to store plots
    if subject.thetaScale
        folderName = fullfile(pwd, 'Plots', string(subject.name), ...
            'ThetaScale');
    else
        folderName = fullfile(pwd, 'Plots', string(subject.name));
    end
    
    % Setting this flag to false initially. If the subject has valid
    % data files within their folder, will set to true. If not, this
    % function terminates early to avoid errors
    hasData = false;
    
    % Loop through each protocol and plot
    for i=1:length(info)
        % Skip this protocol if it was not selected
        if ~info(i).include, continue; end
        
        % Get information about current experiment from info struct
        experimentName = info(i).name;
        csvName = info(i).csvName;
        color = info(i).color;
        
        % Read in data
        [data, incorrect] = readCsv(csvName, subject.name);
        
        % Continue to next protocol if no data was found
        if isempty(data), continue; end
        
        % Remove columns containing incorrect/correct and target/distractor
        data(:,4) = []; data(:,3) = [];
        
        % If this point is reached, the subject had valid data. Reverse
        % hasData flag, create folder for plot output, and create combined
        % linear graph
        if ~hasData
            hasData = true;
            mkdir(folderName);
            mkdir(fullfile(folderName, 'TIF'));
            linearGraph = figure();
        end
        
        % Create figures for single linear graph (one protocol only),
        % accuracy vs. rotation plot, and Chi^2 vs. fit parameter plots
        singleLinearGraph = figure(); accuracyPlot = figure();
        negChiSqPlot = figure(); posChiSqPlot = figure();
        
        % Returns an matrix with unique rotations in column 1, response
        % accuracy percentages in column 2, and standard errors in column 3
        mistakes = calculateAccuracy(data, incorrect);
        
        % Average all reaction time measurements for each face rotation
        data = averageData(data, 1, 2);
        
        % Split data into positive and negative rotations
        [negRotations, posRotations] = splitRotations(data, 0);
        
        % If 1-cos(theta) scale was selected, convert data
        if subject.thetaScale
            [negRotations, posRotations] = convertToTheta(negRotations, ...
                posRotations);
        end
        
        % ----------------------------------------------------------------
        % ----------- Fit and graph negative rotations -------------------
        
        % Estimate fit parameters for negative rotations
        approx = polyfit(negRotations(:,1), negRotations(:,2), 1);
        
        % Calculate fit parameters for negative face rotations via Chi^2 
        % minimization and plot Chi^2 vs. slope and intercept as a heatmap 
        % about the minimum
        [params, paramOutput] = twoParamChiSq(negRotations,experimentName, ...
            approx,'neg',paramOutput,negChiSqPlot);
        
        % Graph negative rotations on combined and single linear graphs
        pointSlope(experimentName, negRotations, params, color, ...
            linearGraph);
        pointSlope(experimentName, negRotations, params, color, ...
            singleLinearGraph);
        
        % ----------------------------------------------------------------
        % ----------- Fit and graph positive rotations -------------------
        
        % Estimate fit parameters for positive rotations
        approx = polyfit(posRotations(:,1), posRotations(:,2), 1);
        
        % Calculate fit parameters for positive face rotations via Chi^2 
        % minimization and plot Chi^2 vs. slope and intercept as a heatmap 
        % about the minimum
        [params, paramOutput] = twoParamChiSq(posRotations,experimentName,approx,...
            'pos',paramOutput,posChiSqPlot);
        
        % Graph positive rotations on combined and single linear graphs
        pointSlope(experimentName, posRotations, params, color, linearGraph);
        pointSlope(experimentName, posRotations, params, color, ...
            singleLinearGraph);
        
        % Set x axes label and limits based upon whether scale is linear or
        % 1-cos(theta)/cos(theta)-1
        if subject.thetaScale
            x_label = 'Face Orientation (1-Cos(°)/Cos(°)-1)';
            x_lim = [(min(negRotations(:,1))-0.1) (max(posRotations(:,1))+0.1)];
        else
            x_lim = [(min(negRotations(:,1))-10) (max(posRotations(:,1))+10)];
            x_label = 'Face Orientation (°)';
        end
        
        % Format individual linear graph (one protocol only)
        formatFigure(singleLinearGraph, 'Reaction Time vs. Face Orientation', ...
            x_label, 'Reaction Time (ms)', x_lim, [-inf inf]);
        
        % Plot response accuracy vs. face rotation
        plotAccuracy(mistakes, color, info(i), accuracyPlot);
        
        % ----------------------------------------------------------------
        % ------- Saving all figures except combined linear --------------
        
        % Arrays of figures & names to loop through and save/close
        figs = [singleLinearGraph, negChiSqPlot, posChiSqPlot, ...
                accuracyPlot];
%         figNames = ['_Linear_Fit', '_Neg_Chi_Sq', '_Pos_Chi_Sq',...
%             '_Accuracy_Plot'];
        figNames = ["Linear", "Neg_ChiSq", "Pos_ChiSq","Accuracy"];
        
        % Loop through each plot and save as .png and .tif
        if subject.savePlots
            for j=1:length(figs)
                saveFig(figs(j), subject, info(i).name, figNames(j), folderName);
            end
        end
        
        % Close figures
        for j=1:length(figs)
            close(figs(j));
        end
    end
    
    % If the subject's data folder was empty, function returns here
    if ~hasData, return; end
    
    % ----------------------------------------------------------------
    % ------- Saving and formatting combined linear graph ------------
    
    % Format, save, and close combined linear graph
    formatFigure(linearGraph, 'Reaction Time vs. Face Orientation', ...
        x_label, 'Reaction Time (ms)', x_lim, [-inf inf]);
    if subject.savePlots
        saveFig(linearGraph, subject, "Combined", "Linear", folderName);
    end
    close(linearGraph);
    
    % ----------------------------------------------------------------
    % ----------- Writing fit parameters to spreadsheet --------------
        
    % Print fit parameters to spreadsheet
    if subject.saveParams
        printFitParameters(subject, paramOutput);
    end
end