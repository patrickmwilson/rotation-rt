function [negOrientation, posOrientation] = convertToTheta(negOrientation, posOrientation)

    for j=1:length(negOrientation)
        negOrientation(j,1) = deg2rad(negOrientation(j,1));
        posOrientation(j,1) = deg2rad(posOrientation(j,1));

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