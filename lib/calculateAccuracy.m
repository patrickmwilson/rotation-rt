function mistakes = calculateAccuracy(data, incorrect)
    mistakes = [];

    mistakes(:,1) = unique(data(:,1));
    mistakes(:,2) = zeros(length(mistakes), 1);

    for j=1:length(incorrect)
        idx = find(mistakes(:,1) == incorrect(j, 1));
        mistakes(idx, 2) = mistakes(idx, 2) + 1;
    end

    for j=1:length(mistakes)
        numWrong = mistakes(j,2);
        numCorrect = length(find(data(:,1) == mistakes(j,1)));

        total = numWrong + numCorrect;

        proportionCorrect = numCorrect/(numCorrect + numWrong);

        percentCorrect = proportionCorrect*100;

        serror = sqrt(proportionCorrect*((1-proportionCorrect)/total));

        mistakes(j,2) = percentCorrect;
        mistakes(j,3) = serror*100;
    end
end