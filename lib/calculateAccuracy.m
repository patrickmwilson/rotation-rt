% calculateAccuracy.m
%
% Takes a matrix of data points corresponding to correct answers and
% another corresponding to incorrect answers. Returns an x-by-3 matrix
% containing the response accuracy rate for each unique value in the first 
% column (independent var/rotation). Column 1 contains the rotation in
% degrees, column 2 contains the percentage correct (ranging from 0 - 100),
% and column 3 contains the standard error of the percentage.
%
function mistakes = calculateAccuracy(data, incorrect)
    mistakes = [];
    
    % Create a matrix with unique rotations in column 1 and zeros in column
    % 2
    mistakes(:,1) = unique(data(:,1));
    mistakes(:,2) = zeros(length(mistakes), 1);

    % Loop through the matrix of incorrect responses. For each row, find
    % the index of the matching rotation in the mistakes matrix and add one
    % to the second column of that row
    for j=1:size(incorrect, 1)
        idx = find(mistakes(:,1) == incorrect(j, 1));
        mistakes(idx, 2) = mistakes(idx, 2) + 1;
    end
    
    % Loop through the mistakes matrix and calculate the response accuracy
    % percentage for each rotation, as well as the standard error.
    for j=1:length(mistakes)
        numWrong = mistakes(j,2);
        numCorrect = length(find(data(:,1) == mistakes(j,1)));

        total = numWrong + numCorrect;

        proportionCorrect = numCorrect/(numCorrect + numWrong);

        percentCorrect = proportionCorrect*100;
        
        % Assuming a binomial distribution, SE = sqrt(p*((1-p)/n)), where p
        % is the proportion correct (ranging from 0 - 1) and n is the total
        % number of measurements taken at that rotation
        serror = sqrt(proportionCorrect*((1-proportionCorrect)/total));

        mistakes(j,2) = percentCorrect;
        mistakes(j,3) = serror*100;
    end
end