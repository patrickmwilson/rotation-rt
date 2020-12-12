% convertToTheta.m
%
% Accepts the matrices of data taken at negative and positive rotations as
% input arguments. Converts the rotations from degrees to cos(theta) - 1 if
% they are < 0, and 1 - cos(theta) if they are > 0.

function [negOrientation, posOrientation] = convertToTheta(negOrientation, posOrientation)

    for j=1:length(negOrientation)
        % Convert from degrees to radians
        negOrientation(j,1) = deg2rad(negOrientation(j,1));
        posOrientation(j,1) = deg2rad(posOrientation(j,1));
        
        % dont remember how this math works
        if negOrientation(j,1) < 0
            negOrientation(j,1) = cos(negOrientation(j,1)) -1;
        else
            negOrientation(j,1) = 1 - cos(negOrientation(j,1));
        end

        if posOrientation(j,1) < 0
            posOrientation(j,1) = cos(posOrientation(j,1)) -1;
        else
            posOrientation(j,1) = 1 - cos(posOrientation(j,1));
        end
    end

end