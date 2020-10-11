function [target, distractor] = splitByTarget(data, targetCol)
    target = []; distractor = [];
    for i=1:length(data)
        if data(i, targetCol) == 1
            target = [target; data(i,:)];
        else
            distractor = [distractor; data(i,:)];
        end
    end
end