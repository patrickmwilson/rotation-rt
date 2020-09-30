clear variables; close all;

% Add helper functions to path
addpath(fullfile(pwd, 'lib')); 

% Supress directory warnings
warning('off','MATLAB:MKDIR:DirectoryExists');

mkdir(fullfile(pwd,'Parameters'));
mkdir(fullfile(pwd,'Plots'));

experimentName = 'Face Horizontal Rotation RT';
subjectName = 'PAT';

data = readCsv(experimentName, subjectName);

i = 1;
while i <= length(data)
    if data(i, 4) == 0
        data(i,:) = [];
    else
        i = i+1;
    end
end

data(:,4) = [];
data(:,3) = [];

data = averageData(data, 1, 2);

approx = polyfit(data(:,1), data(:,2), 1);

chiSqPlot = figure();

params = twoParamChiSq(data,experimentName,approx,chiSqPlot);

linearGraph = figure();

pointSlope(data,params,[0.4 0.8 0.5],linearGraph);

ylabel('Reaction Time (ms)');
xlabel('Face Orientation (°)');
title('Reaction Time vs. Face Orientation');








