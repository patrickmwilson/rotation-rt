clear variables; close all;

% Add helper functions to path
addpath(fullfile(pwd, 'lib')); 

% Supress directory warnings
warning('off','MATLAB:MKDIR:DirectoryExists');

mkdir(fullfile(pwd,'Parameters'));
mkdir(fullfile(pwd,'Plots'));

subjectName = 'PAT';
lim = 100;
% 
% info = struct('name', 'Pitch', 'csvName', 'Face Pitch Rotation RT', 'negColor', [0 0.8 0.8], 'posColor', [0.86 0.27 0.07]);
% 
% info = repmat(info, 1, 3);
% 
% info(2).name = 'Yaw';
% info(2).csvName = 'Face Yaw Rotation RT';
% info(2).negColor = [0.9 0.3 0.9];
% info(2).posColor = [0.5 0 0.9];
% 
% info(3).name = 'Roll';
% info(3).csvName = 'Face Roll Rotation RT';
% info(3).negColor = [1 0.6 0];
% info(3).posColor = [0 0 0];

% info = struct('name', 'Unfamiliar Similar', ...
%     'csvName', 'Face Roll Rotation RT Similar', 'color', [0 0.8 0.8], ...
%     'posColor', [0.86 0.27 0.07]);
% 
% info = repmat(info, 1, 3);
% 
% info(2).name = 'Unfamiliar Distinct';
% info(2).csvName = 'Face Roll Rotation RT Distinct';
% info(2).color = [0.86 0.27 0.07];
% 
% info(3).name = 'Familiar';
% info(3).csvName = 'Face Roll Rotation RT Familiar';
% info(3).color = [1 0.6 0];

% 
% infoCsv = fullfile(pwd,'lib','struct_templates','protocol_info.csv');
% info = table2struct(readtable(infoCsv));
% 
% for i=1:length(info)
%     info(i).negcolor = str2num(info(i).negcolor);
%     info(i).poscolor = str2num(info(i).poscolor);
% end

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
    %posColor = info(i).posColor;
    
    data = readCsv(csvName, subjectName);
    
    if isempty(data)
        continue;
    end
    
    negChiSqPlot = figure();
    posChiSqPlot = figure();
%     
%     mistakes(:,1) = unique(data(:,1));
%     mistakes(:,2) = zeros(length(mistakes), 1);

    j = 1;
    while j <= length(data)
        if data(j, 4) == 0
            data(j,:) = [];

%             idx = find(mistakes(:,1) == data(j, 1));
% 
%             mistakes(idx, 2) = mistakes(idx, 2) + 1;
        else
            j = j+1;
        end
    end
    
%     for i=1:length(mistakes)
%         numWrong = mistakes(i,2);
%         numCorrect = length(find(data(:,1) == mistakes(i,1)));
% 
%         percentCorrect = (numCorrect/(numCorrect + numWrong))*100;
% 
%         mistakes(i,2) = percentCorrect;
%     end
    
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
    
    
end
% 
% 
% negChiSqPlot = figure();
% posChiSqPlot = figure();
% 
% data = readCsv(experimentName, subjectName);
% 
% mistakes(:,1) = unique(data(:,1));
% mistakes(:,2) = zeros(length(mistakes), 1);
% 
% i = 1;
% while i <= length(data)
%     if data(i, 4) == 0
%         data(i,:) = [];
%         
%         idx = find(mistakes(:,1) == data(i, 1));
%         
%         mistakes(idx, 2) = mistakes(idx, 2) + 1;
%     else
%         i = i+1;
%     end
% end
% 
% for i=1:length(mistakes)
%     numWrong = mistakes(i,2);
%     numCorrect = length(find(data(:,1) == mistakes(i,1)));
%     
%     percentCorrect = (numCorrect/(numCorrect + numWrong))*100;
%     
%     mistakes(i,2) = percentCorrect;
% end
% 
% data(:,4) = [];
% data(:,3) = [];
% 
% data = averageData(data, 1, 2);
% 
% [negOrientation, posOrientation] = splitSizes(data, 0);
% 
% approx = polyfit(negOrientation(:,1), negOrientation(:,2), 1);
% 
% params = twoParamChiSq(negOrientation,experimentName,approx,negChiSqPlot);
% 
% pointSlope(negOrientation,params,negColor,linearGraph);
% 
% 
% idx = find(negOrientation(:,1) == 0);
% figure(linearGraph);
% hold on;
% scatter(negOrientation(idx,1), negOrientation(idx,2), 30, 'k', 'filled', ...
%         'DisplayName', 'Reference Orientation');
% 
% 
% 
% approx = polyfit(posOrientation(:,1), posOrientation(:,2), 1);
% 
% params = twoParamChiSq(posOrientation,experimentName,approx,posChiSqPlot);
% 
% pointSlope(posOrientation,params,posColor,linearGraph);


figure(linearGraph);

ylabel('Reaction Time (ms)');
xlabel('Face Orientation (°)');
title(strcat('Reaction Time vs. Face Orientation (', subjectName, ')'));
xlim([-lim lim]);

% xticks(unique(data(:,1)));

legend('show', 'Location', 'best');


% accuracyPlot = figure();
% hold on;
% 
% 
% plot(mistakes(:,1), mistakes(:,2), 'LineStyle', '-', 'Color', [0 0.8 0.8]);
% 
% scatter(mistakes(:,1), mistakes(:,2), 30, [0 0.8 0.8], 'filled', ...
%         'HandleVisibility','off');
% 
% 
% ylabel('Response Accuracy (%)');
% xlabel('Face Orientation (°)');
% title(strcat('Response Accuracy vs. Face Orientation ', type));
% xlim([-lim lim]);
% 
% yticks([70, 75, 80, 85, 90, 95, 100]);
% yticklabels({'70%', '75%', '80%', '85%', '90%', '95%', '100%'});
% 
% ylim([(min(mistakes(:,2))-5) 101]);
% 
% xticks(unique(data(:,1)));






