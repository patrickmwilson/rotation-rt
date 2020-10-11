function [cleanData, outliers] = cleanAndRemoveOutliers(data)
    cleanData = []; outliers = [];
    
    uniques = unique(data(:,1));
    
    for i=1:length(uniques)
        sz = uniques(i, 1);
        indices = find(data(:,1) == sz);

        thisData = [];
        
        for j=1:length(indices)
            idx = indices(j);
            thisData = [thisData; data(idx,:)];
        end

        
        [newData, theseOutliers] = removeOutliers(thisData, [], 2.5, 2);
        
        cleanData = [cleanData; newData];
        outliers = [outliers; theseOutliers];
    end
end