
function [upright, inverted] = splitOrientations(data)

    upright = []; inverted = [];

    for i=1:length(data)
        if data(i,1) == 0
            upright = [upright; data(i,:)];
        else
            inverted = [inverted; data(i,:)];
        end
    end

end