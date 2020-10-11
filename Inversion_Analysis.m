clear variables; close all;

% Add helper functions to path
addpath(fullfile(pwd, 'lib')); 

% Supress directory warnings
warning('off','MATLAB:MKDIR:DirectoryExists');

mkdir(fullfile(pwd,'Parameters'));
mkdir(fullfile(pwd,'Plots'));

exp = ' (Inverted Reference)';


data = readCsv('Face Inversion Inverted Reference', 'PAT');

%data = removeIncorrect(data, 4);

i = 1;
while i <= length(data)
    if data(i, 4) == 0
        data(i,:) = [];
    else
        i = i+1;
    end
end

[upright, inverted] = splitOrientations(data);

figure();
hold on;

uprightMean = mean(upright(:,2));
invertedMean = mean(inverted(:,2));

txt = '%s Mean: %4.1f';

histogram(upright(:,2), 20, 'FaceColor', [0 0.8 0.8], ...
    'DisplayName', sprintf(txt, 'Upright', uprightMean));
histogram(inverted(:,2), 20, 'FaceColor', [0.86 0.27 0.27], ...
    'DisplayName', sprintf(txt, 'Inverted', invertedMean));



[~, p] = ttest2(upright(:,2), inverted(:,2));

txt = 'p-value: %5.4f';

line(nan, nan, 'Linestyle', 'none', 'Marker', 'none', 'Color', 'none', ...
        'DisplayName', ...
        sprintf(txt, p));

legend('show', 'Location', 'best');
xlabel('Reaction Time (ms)');
title(strcat('Face RT', exp));



figure();
hold on;

[uprightTarget, uprightDistractor] = splitByTarget(upright, 3);
[invertedTarget, invertedDistractor] = splitByTarget(inverted, 3);

uprightTarget = removeOutliers(uprightTarget, [], 2.5, 2);
uprightDistractor = removeOutliers(uprightDistractor, [], 2.5, 2);
invertedTarget = removeOutliers(invertedTarget, [], 2.5, 2);
invertedDistractor = removeOutliers(invertedDistractor, [], 2.5, 2);


uprightTargetMean = mean(uprightTarget(:,2));
uprightTargetError = ...
    std(uprightTarget(:,2))/sqrt(length(uprightTarget));

invertedTargetMean = mean(invertedTarget(:,2));
invertedTargetError = ...
    std(invertedTarget(:,2))/sqrt(length(invertedTarget));

txt = '%s Mean: %4.1f';

histogram(uprightTarget(:,2), 20, 'FaceColor', [0 0.8 0.8], ...
    'DisplayName', sprintf(txt, 'Upright', uprightTargetMean));
histogram(invertedTarget(:,2), 20, 'FaceColor', [0.86 0.27 0.27], ...
    'DisplayName', sprintf(txt, 'Inverted', invertedTargetMean));



[h, p] = ttest2(uprightTarget(:,2), invertedTarget(:,2));

txt = 'p-value: %5.4f';

line(nan, nan, 'Linestyle', 'none', 'Marker', 'none', 'Color', 'none', ...
        'DisplayName', ...
        sprintf(txt, p));

legend('show', 'Location', 'best');
xlabel('Reaction Time (ms)');
title(strcat('Face RT for Target Face', exp)); 




figure();
hold on;

uprightDistractorMean = mean(uprightDistractor(:,2));
uprightDistractorError = ...
    std(uprightDistractor(:,2))/sqrt(length(uprightDistractor));

invertedDistractorMean = mean(invertedDistractor(:,2));
invertedDistractorError = ...
    std(invertedDistractor(:,2))/sqrt(length(invertedDistractor));

txt = '%s Mean: %4.1f';

histogram(uprightDistractor(:,2), 20, 'FaceColor', [0 0.8 0.8], ...
    'DisplayName', sprintf(txt, 'Upright', uprightDistractorMean));
histogram(invertedDistractor(:,2), 20, 'FaceColor', [0.86 0.27 0.27], ...
    'DisplayName', sprintf(txt, 'Inverted', invertedDistractorMean));



[h, p] = ttest2(uprightDistractor(:,2), invertedDistractor(:,2));

txt = 'p-value: %5.4f';

line(nan, nan, 'Linestyle', 'none', 'Marker', 'none', 'Color', 'none', ...
        'DisplayName', ...
        sprintf(txt, p));

legend('show', 'Location', 'best');
xlabel('Reaction Time (ms)');
title(strcat('Face RT for Distractor Face', exp)); 



figure();

% X = categorical({'Target Upright','Target Inverted','Distractor Upright','Distractor Inverted'});
% X = reordercats(X,{'Target Upright','Target Inverted','Distractor Upright','Distractor Inverted'});
% Y = [uprightTargetMean invertedTargetMean uprightDistractorMean invertedDistractorMean];

X = [1,2,3,4];
Y = [uprightTargetMean invertedTargetMean uprightDistractorMean invertedDistractorMean];
err = [uprightTargetError invertedTargetError uprightDistractorError invertedDistractorError];
bar(X,Y);
hold on;

errorbar(X, Y, err, 'vertical','.', 'HandleVisibility', 'off', ...
    'Color', [0 0 0]);

xticklabels({'Target Upright','Target Inverted','Distractor Upright','Distractor Inverted'});



title(strcat('Mean Reaction Times', exp)); 
ylabel('Reaction Time (ms)');
ylim([(min(Y)-30) (max(Y)+30)]);







