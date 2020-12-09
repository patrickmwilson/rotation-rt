% splitRotations.m
%
% Takes a matrix of data with the independent variable in the first column
% (rotation) and a reference rotation as input arguments. Splits the matrix
% of data into two new matrices, one including only rows with rotations
% less than or equal to the reference rotation, and one including only rows 
% with rotations greater than or equal to the reference rotation. Reference
% angle is 0 in our analysis.
function [negRotations, posRotations] = splitRotations(data, referenceAngle)
    
    % Create empty matrices for output
    posRotations = []; negRotations = [];
    
    % Loop through every row in the data matrix
    for i=1:length(data)
        % If the independent variable in column 1 (rotation) of this row 
        % matches the reference angle, copy the row into both output
        % matrices
        if data(i,1) == referenceAngle
            posRotations = [posRotations; data(i,:)];
            negRotations = [negRotations; data(i,:)];
        % Special case for the roll experiment. 180° and -180° are
        % equivalent, so I did not include -180° in the PsychoPy
        % experiment. Adds 180° rotation data to positive rotation matrix,
        % then changes it to -180° and adds it to negative rotation matrix.
        elseif data(i,1) == 180
            posRotations = [posRotations; data(i,:)];
            data(i,1) = -180;
            negRotations = [negRotations; data(i,:)];
        % If the independent variable in column 1 (rotation) of this row 
        % is greater than the reference angle, copy the row into the
        % positive sizes matrix
        elseif data(i,1) > referenceAngle
            posRotations = [posRotations; data(i,:)];
        % If the independent variable in column 1 (rotation) of this row 
        % is less than the reference angle, copy the row into the
        % negative sizes matrix
        else
            negRotations = [negRotations; data(i,:)];
        end
    end

end