function [paramOutput, incorrectPercentages, rtAverages, logylim] = analyzeData(data, info, subject, paramOutput, logPlot, smChiSqPlot, lgChiSqPlot)

    lgColor = [0 0.8 0.8];
    smColor = [0.86 0.27 0.07];
    
    [data, ~, incorrectPercentages] = cleanAndRemoveOutliers(data, subject);
    
    data(:,3) = [];
    
    data = averageData(data, 1, 2);
    
    rtAverages = tableFromMatrix(data, subject);
    
    data(:,1) = log10(data(:,1));

    [smSizes, lgSizes] = splitSizes(data, log10(info.reference_angle));
    
    
    approx = polyfit(smSizes(:,1), smSizes(:,2), 1);
    
    [params, paramOutput] = twoParamChiSq(smSizes, info, 'sm', approx, ...
        paramOutput, smChiSqPlot);
    
    pointSlope(smSizes, params, smColor, logPlot);
    
    idx = find(smSizes(:,1) == max(smSizes(:,1)));
    
    figure(logPlot); hold on;

    scatter(smSizes(idx,1), smSizes(idx,2), 30, 'k', 'filled', ...
        'DisplayName', 'Reference Size');
    
    
    
    approx = polyfit(lgSizes(:,1), lgSizes(:,2), 1);
    
    [params, paramOutput] = twoParamChiSq(lgSizes, info, 'lg', approx, ...
        paramOutput, lgChiSqPlot);
    
    pointSlope(lgSizes, params, lgColor, logPlot);
    
    figure(logPlot); hold on;

    scatter(smSizes(idx,1), smSizes(idx,2), 30, 'k', 'filled', ...
        'HandleVisibility', 'off');
    
    forLims = [smSizes; lgSizes];
    logylim = [(min(forLims(:,2))-20) (max(forLims(:,2))+20)];


end