% cleanAndRemoveOutliers.m
%
% Removes outliers from the given data matrix. Finds all the unique values
% in column 1 (rotations/independent variable). Loops through these unique
% values, creating a matrix containing all reaction time measurements at
% that rotation. From this distribution of measurements, outliers
% (measurements >+/-2.5 SD from the mean) are recursively removed. See
% removeOutliers.m for more information.
%
function [cleanData, outliers] = cleanAndRemoveOutliers(data)
    cleanData = []; outliers = [];
    
    % Get unique rotations (independent variable)
    uniques = unique(data(:,1));
    
    % Loop through unique rotations
    for i=1:length(uniques)
        
        % Find the indices of all rows in the matrix in which the rotation
        % matches our current rotation
        rotation = uniques(i, 1);
        indices = find(data(:,1) == rotation);
        
        % Copy all rows in the matrix with our current rotation into a new
        % matrix
        thisData = [];
        for j=1:length(indices)
            idx = indices(j);
            thisData = [thisData; data(idx,:)];
        end
        
        % Recursively remove reaction time measurements greater than 2.5
        % standard deviations from the mean
        [newData, theseOutliers] = removeOutliers(thisData, [], 2.5, 2);
        
        % Concatenate the resulting data and the outliers with the existing
        % matrices
        cleanData = [cleanData; newData];
        outliers = [outliers; theseOutliers];
    end
end