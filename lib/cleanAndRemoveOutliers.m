function [cleanData, outliers, incorrectPercentages] = cleanAndRemoveOutliers(data, subject)
    cleanData = []; outliers = [];
    
    sizes = unique(data(:,1));
    
    for i=1:length(sizes)
        sz = sizes(i, 1);
        indices = find(data(:,1) == sz);
        
        incorrect = 0;
        thisData = [];
        
        for j=1:length(indices)
            idx = indices(j);
            if(data(idx, 3) == 0)
                incorrect = incorrect + 1;
            else
                thisData = [thisData; data(idx,:)];
            end
        end
        
        percentIncorrect = (incorrect/length(indices))*100;
        sizes(i,2) = percentIncorrect;
        
        [newData, theseOutliers] = removeOutliers(thisData, [], 2.5, 2);
        
        cleanData = [cleanData; newData];
        outliers = [outliers; theseOutliers];
    end
    
    incorrectPercentages = tableFromMatrix(sizes, subject);
end