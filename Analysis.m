clear variables; close all;

% Add helper functions to path
addpath(fullfile(pwd, 'lib')); 

% Supress directory warnings
warning('off','MATLAB:MKDIR:DirectoryExists');

mkdir(fullfile(pwd,'Parameters'));
mkdir(fullfile(pwd,'Plots'));

subjectName = string(inputdlg({'Subject name (Matching their data folder)'}, ...
            'Session Info', [1 70], {''}));

info = struct('name', NaN, 'csvName', NaN, 'color', NaN);

info = repmat(info, 1, 3);

info(1).name = 'Pitch';
info(1).csvName = 'Face Pitch Rotation RT';
info(1).color = [0 0.8 0.8];

info(2).name = 'Yaw';
info(2).csvName = 'Face Yaw Rotation RT';
info(2).color = [0.86 0.27 0.07];

info(3).name = 'Roll';
info(3).csvName = 'Face Roll Rotation RT';
info(3).color = [1 0.6 0];

dataAnswer = questdlg('Set axis x limits', ...
        'Data Selection', 'Automatically', 'Manually', 'Cancel', 'Automatically');
if strcmp(dataAnswer,'Cancel')
    return;
elseif strcmp(dataAnswer, 'Manually')
    lim = str2double(cell2mat(inputdlg({'x axis limits (50 for pitch only, 95 for yaw, 185 for roll'}, ...
            'Session Info', [1 70], {''})));
else
    lim = 185;
end

linearGraph = figure();

for i=1:length(info)
    if i ~= 3
        continue;
    end
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
    
    %[data, ~] = cleanAndRemoveOutliers(data);

    data = averageData(data, 1, 2);

    [negOrientation, posOrientation] = splitSizes(data, 0);
    
%     for j=1:length(negOrientation)
%         negOrientation(j,1) = deg2rad(negOrientation(j,1));
%         posOrientation(j,1) = deg2rad(posOrientation(j,1));
%         
%         if negOrientation(j,1) < 0
%             negOrientation(j,1) = cos(negOrientation(j,1)) -1;
%         else
%             negOrientation(j,1) = 1 - cos(negOrientation(j,1));
%         end
%         
%         if posOrientation(j,1) < 0
%             posOrientation(j,1) = cos(posOrientation(j,1)) -1;
%         else
%             posOrientation(j,1) = 1 - cos(posOrientation(j,1));
%         end
%         
%     end

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
% xlim([min(negOrientation(:,1)) max(posOrientation(:,1))]);
%xticks([-90, -75, -60, -45, -30, -15, 0, 15, 30, 45, 60, 75, 90]);

legend('show', 'Location', 'best');



% 
% for i=1:length(xv)
%     if xv(i) < 0
%         disp(1 - cos(xv(i)));
%     elseif xv(i) > 0
%         disp(-1 + cos(xv(i)));
%     else
%         disp(xv(i));
%     end
% end
