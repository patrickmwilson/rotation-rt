function analyzeSubject(subject, info)

    fileName = fullfile(pwd,'lib','struct_templates', ...
            'param_struct.csv');
    paramOutput = table2struct(readtable(fileName));
    paramOutput.name = subject.name;

    linearGraph = figure();

    for i=1:length(info)
        if ~info(i).include
            continue;
        end
        experimentName = info(i).name;
        csvName = info(i).csvName;
        color = info(i).color;

        [data, incorrect] = readCsv(csvName, subject.name);

        if isempty(data)
            continue;
        end

        negChiSqPlot = figure();
        posChiSqPlot = figure();

        mistakes = [];

        mistakes(:,1) = unique(data(:,1));
        mistakes(:,2) = zeros(length(mistakes), 1);

        for j=1:length(incorrect)
            idx = find(mistakes(:,1) == incorrect(j, 1));
            mistakes(idx, 2) = mistakes(idx, 2) + 1;
        end

        for j=1:length(mistakes)
            numWrong = mistakes(j,2);
            numCorrect = length(find(data(:,1) == mistakes(j,1)));
            
            total = numWrong + numCorrect;
            
            proportionCorrect = numCorrect/(numCorrect + numWrong);

            percentCorrect = proportionCorrect*100;
            
            serror = sqrt(proportionCorrect*((1-proportionCorrect)/total));
            
            mistakes(j,2) = percentCorrect;
            mistakes(j,3) = serror*100;
            
        end

        data(:,4) = [];
        data(:,3) = [];

        data = averageData(data, 1, 2);

        [negOrientation, posOrientation] = splitSizes(data, 0);

        if subject.thetaScale
            for j=1:length(negOrientation)
                negOrientation(j,1) = deg2rad(negOrientation(j,1));
                posOrientation(j,1) = deg2rad(posOrientation(j,1));

                if negOrientation(j,1) < 0
                    negOrientation(j,1) = cos(negOrientation(j,1)) -1;
                else
                    negOrientation(j,1) = 1 - cos(negOrientation(j,1));
                end

                if posOrientation(j,1) < 0
                    posOrientation(j,1) = cos(posOrientation(j,1)) -1;
                else
                    posOrientation(j,1) = 1 - cos(posOrientation(j,1));
                end
            end
        end

        approx = polyfit(negOrientation(:,1), negOrientation(:,2), 1);

        [params, paramOutput] = twoParamChiSq(negOrientation,experimentName,approx,...
            'neg',paramOutput,negChiSqPlot);

        pointSlope(experimentName, negOrientation,params,color,linearGraph);


        idx = find(negOrientation(:,1) == 0);
        figure(linearGraph);
        hold on;
        scatter(negOrientation(idx,1), negOrientation(idx,2), 30, 'k', 'filled', ...
            'HandleVisibility', 'off');
        
        if subject.thetaScale
            xlim([(min(negOrientation(:,1))-0.1) (max(posOrientation(:,1))+0.1)]);
        else
            xlim([(min(negOrientation(:,1))-10) (max(posOrientation(:,1))+10)]);
        end

        approx = polyfit(posOrientation(:,1), posOrientation(:,2), 1);

        [params, paramOutput] = twoParamChiSq(posOrientation,experimentName,approx,...
            'pos',paramOutput,posChiSqPlot);

        pointSlope(experimentName, posOrientation,params,color,linearGraph);

        accuracyPlot = figure;
        hold on;
        
        errorbar(mistakes(:,1), mistakes(:,2), mistakes(:,3), 'vertical','.', ...
            'HandleVisibility', 'off', 'Color', [0.43 0.43 0.43], ...
            'CapSize', 0);

%         plot(mistakes(:,1), mistakes(:,2), 'LineStyle', '-', 'Color', color, ...
%             'DisplayName', info(i).name);

        scatter(mistakes(:,1), mistakes(:,2), 30, color, 'filled', ...
                'HandleVisibility', 'off');
            
%         xfit = linspace(min(mistakes(:,1)), max(mistakes(:,1)));
%         
%         yfit = spline(mistakes(:,1), mistakes(:,2), xfit);
%         
%         plot(xfit, yfit, 'LineStyle', '-', 'Color', color, ...
%             'DisplayName', info(i).name);

        [f,~,out] = fit(mistakes(:,1), mistakes(:,2), 'smoothingspline');
        disp(out.p);
        
        l = plot(f);
        l.LineStyle = '-';
        l.Color = color;
        l.DisplayName = info(i).name;
        l.LineWidth = 1;
        
            
        
        ylabel('Response Accuracy (%)');
        xlabel('Face Orientation (°)');
        title('Response Accuracy vs. Face Orientation');
        xlim([(min(data(:,1))-5) (max(data(:,1))+5)]);

        yticks([70, 75, 80, 85, 90, 95, 100]);
        yticklabels({'70%', '75%', '80%', '85%', '90%', '95%', '100%'});

        ylim([80 101]);

        xticks(unique(data(:,1)));
        
        legend('show', 'Location', 'best');

    end

    figure(linearGraph);

    ylabel('Reaction Time (ms)');
    if subject.thetaScale
        xlabel('Face Orientation (1-Cos(°)/Cos(°)-1)');
    else
        xlabel('Face Orientation (°)');
    end
    title(strcat('Reaction Time vs. Face Orientation (', subject.name, ')'));
    %xlim([-lim lim]);
    % xlim([min(negOrientation(:,1)) max(posOrientation(:,1))]);
    %xticks([-90, -75, -60, -45, -30, -15, 0, 15, 30, 45, 60, 75, 90]);

    legend('show', 'Location', 'best');
    

    if subject.saveParams
        paramOutput = struct2table(paramOutput);
        fileName = fullfile(pwd, 'Parameters', 'fit_parameters.csv');
        if(exist(fileName, 'file') ~= 2) % If file does not exist, print column names
            writetable(paramOutput,fileName,'WriteRowNames',true);
        else
            writetable(paramOutput,fileName,'WriteRowNames',false, ...
                'WriteMode', 'Append')
        end
    end

end