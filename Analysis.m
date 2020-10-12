clear variables; close all;

% Add helper functions to path
addpath(fullfile(pwd, 'lib')); 

% Supress directory warnings
warning('off','MATLAB:MKDIR:DirectoryExists');

mkdir(fullfile(pwd,'Parameters'));
mkdir(fullfile(pwd,'Plots'));

subjectName = string(inputdlg({'Subject name (Matching their data folder)'}, ...
            'Session Info', [1 70], {''}));
lim = 100;

info = struct('name', 'Pitch', ...
        'csvName', 'Face Pitch Rotation RT', 'color', [0 0.8 0.8]);

info = repmat(info, 1, 3);

info(2).name = 'Yaw';
info(2).csvName = 'Face Yaw Rotation RT';
info(2).color = [0.86 0.27 0.07];

info(3).name = 'Roll';
info(3).csvName = 'Face Roll Rotation RT';
info(3).color = [1 0.6 0];


linearGraph = figure();

for i=1:length(info)
    experimentName = info(i).name;
    csvName = info(i).csvName;
    color = info(i).color;
    
    data = readCsv(csvName, subjectName);
    
    if isempty(data)
        continue;
    end
    
    negChiSqPlot = figure();
    posChiSqPlot = figure();
    
    mistakes = [];
    
    mistakes(:,1) = unique(data(:,1));
    mistakes(:,2) = zeros(length(mistakes), 1);

    j = 1;
    while j <= length(data)
        if data(j, 4) == 0
            data(j,:) = [];

            idx = find(mistakes(:,1) == data(j, 1));

            mistakes(idx, 2) = mistakes(idx, 2) + 1;
        else
            j = j+1;
        end
    end
    
    for j=1:length(mistakes)
        numWrong = mistakes(j,2);
        numCorrect = length(find(data(:,1) == mistakes(j,1)));

        percentCorrect = (numCorrect/(numCorrect + numWrong))*100;

        mistakes(j,2) = percentCorrect;
    end
    
    data(:,4) = [];
    data(:,3) = [];

    data = averageData(data, 1, 2);

    [negOrientation, posOrientation] = splitSizes(data, 0);

    approx = polyfit(negOrientation(:,1), negOrientation(:,2), 1);

    params = twoParamChiSq(negOrientation,experimentName,approx,negChiSqPlot);

    pointSlope(experimentName, negOrientation,params,color,linearGraph);


    idx = find(negOrientation(:,1) == 0);
    figure(linearGraph);
    hold on;
    scatter(negOrientation(idx,1), negOrientation(idx,2), 30, 'k', 'filled', ...
        'HandleVisibility', 'off');



    approx = polyfit(posOrientation(:,1), posOrientation(:,2), 1);

    params = twoParamChiSq(posOrientation,experimentName,approx,posChiSqPlot);

    pointSlope(experimentName, posOrientation,params,color,linearGraph);
    
    
    accuracyPlot = figure();
    hold on;


    plot(mistakes(:,1), mistakes(:,2), 'LineStyle', '-', 'Color', [0 0.8 0.8]);

    scatter(mistakes(:,1), mistakes(:,2), 30, [0 0.8 0.8], 'filled', ...
            'HandleVisibility','off');


    ylabel('Response Accuracy (%)');
    xlabel('Face Orientation (°)');
    title(strcat('Response Accuracy vs. Face Orientation (', experimentName, ')'));
    xlim([(min(data(:,1))-5) (max(data(:,1))+5)]);

    yticks([70, 75, 80, 85, 90, 95, 100]);
    yticklabels({'70%', '75%', '80%', '85%', '90%', '95%', '100%'});

    ylim([(min(mistakes(:,2))-5) 101]);

    xticks(unique(data(:,1)));
    
    
end

figure(linearGraph);

ylabel('Reaction Time (ms)');
xlabel('Face Orientation (°)');
title(strcat('Reaction Time vs. Face Orientation (', subjectName, ')'));
xlim([-lim lim]);
xticks([-90, -75, -60, -45, -30, -15, 0, 15, 30, 45, 60, 75, 90]);

legend('show', 'Location', 'best');






