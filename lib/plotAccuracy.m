% plotAccuracy.m
%
% Plots response accuracy vs. face rotation and a smoothed spline fit.
%
function plotAccuracy(mistakes, color, info, fig)

    figure(fig);
    hold on;

    % Plot error bars showing +/- 1 standard error and scatters data
    errorbar(mistakes(:,1), mistakes(:,2), mistakes(:,3), 'vertical','.', ...
        'HandleVisibility', 'off', 'Color', [0.43 0.43 0.43], ...
        'CapSize', 0);
    scatter(mistakes(:,1), mistakes(:,2), 30, color, 'filled', ...
            'HandleVisibility', 'off');
    
    % Smoothed spline fit with automatically calculated smoothing factor
    [f,~,~] = fit(mistakes(:,1), mistakes(:,2), 'smoothingspline');
    
    % Plots spline fit and modifies line properties. Using dot operator to
    % set properties because the plot function with a single input argument
    % (f) as opposed to (x,y) throws an error when the property arguments
    % are included
    l = plot(f);
    l.LineStyle = '-';
    l.Color = color;
    l.DisplayName = info.name;
    l.LineWidth = 1;
    
    % Sets xlim to smallest rotation -5 -> largest rotation +5.
    % Sets ylim to 80% -> 101% if possible to standardize axes between
    % experiments. If mistake rate exceeds 20% ylim minimum is set to
    % minimum success rate - 5
    x_lim = [(min(mistakes(:,1))-5) (max(mistakes(:,1))+5)];
    if min(mistakes(:,2)) >= 80
        y_lim = [80 101];
    else
        y_lim = [(min(mistakes(:,2)) - 5) 101];
    end
    
    % Set x and y ticks, label y ticks as percentages
    xticks(unique(mistakes(:,1)));
    yticks([70, 75, 80, 85, 90, 95, 100]);
    yticklabels({'70%', '75%', '80%', '85%', '90%', '95%', '100%'});
    
    % Formatting figure
    formatFigure(fig, 'Response Accuracy vs. Face Orientation', ...
        'Face Orientation (°)', 'Response Accuracy (%)', x_lim, y_lim);

end