
function [negSizes, posSizes] = splitSizes(data, referenceAngle)

    posSizes = []; negSizes = [];

    for i=1:length(data)
        if data(i,1) == referenceAngle
            posSizes = [posSizes; data(i,:)];
            negSizes = [negSizes; data(i,:)];
        elseif data(i,1) > referenceAngle
            posSizes = [posSizes; data(i,:)];
        else
            negSizes = [negSizes; data(i,:)];
        end
    end

end