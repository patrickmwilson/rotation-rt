function plotAccuracy(mistakes, color, info, subject, folderName, fig)

    figure(fig);
    hold on;

    errorbar(mistakes(:,1), mistakes(:,2), mistakes(:,3), 'vertical','.', ...
        'HandleVisibility', 'off', 'Color', [0.43 0.43 0.43], ...
        'CapSize', 0);

    scatter(mistakes(:,1), mistakes(:,2), 30, color, 'filled', ...
            'HandleVisibility', 'off');

    [f,~,~] = fit(mistakes(:,1), mistakes(:,2), 'smoothingspline');

    l = plot(f);
    l.LineStyle = '-';
    l.Color = color;
    l.DisplayName = info.name;
    l.LineWidth = 1;

    x_lim = [(min(mistakes(:,1))-5) (max(mistakes(:,1))+5)];

    if min(mistakes(:,2)) >= 80
        y_lim = [80 101];
    else
        y_lim = [(min(mistakes(:,2)) - 5) 101];
    end

    xticks(unique(mistakes(:,1)));
    yticks([70, 75, 80, 85, 90, 95, 100]);
    yticklabels({'70%', '75%', '80%', '85%', '90%', '95%', '100%'});

    formatFigure(accuracyPlot, 'Response Accuracy vs. Face Orientation', ...
        'Face Orientation (°)', 'Response Accuracy (%)', x_lim, y_lim);

end