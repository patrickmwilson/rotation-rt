function graphCorrelation(xdata, ydata, slope, intercept, R, reduced_chi_sq, subjectNames, graphNames, fig)

    figure(fig); hold on;

    % Plot error bars 
    errorbar(xdata(:,1),ydata(:,1),xdata(:,2), 'horizontal', ...
        '.', 'HandleVisibility', 'off', ...
        'Color', [0.43 0.43 0.43], ...
        'CapSize', 0);
    errorbar(xdata(:,1),ydata(:,1),ydata(:,2), 'vertical', ...
        '.', 'HandleVisibility', 'off', ...
        'Color', [0.43 0.43 0.43], ...
        'CapSize', 0);

    % Scatter slope parameters
    scatter(xdata(:,1), ydata(:,1), 25, 'k', "filled", ...
        'HandleVisibility', 'off');

    % Add subject names as text to the graph
    if graphNames
        text((xdata(:,1).*1.01), (ydata(:,1).*1.01), subjectNames, ...
            'FontSize', 8);
    end
    
    xfit = linspace((min(xdata(:,1))*0.99), (max(xdata(:,1))*1.01));
    yfit = (xfit*slope)+intercept;
    
    sprintf("R: %2.2f, Reduced Chi^2: %4.2f", R, reduced_chi_sq);
    
    plot(xfit, yfit, 'Color', 'k', 'LineWidth', 1, 'DisplayName', ...
            sprintf("R: %2.2f, Reduced Chi^2: %4.2f", R, reduced_chi_sq));
    
    legend('show', 'Location', 'best');
end