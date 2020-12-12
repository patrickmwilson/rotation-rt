% chisqPlot.m
%
% Graphs a heatmap of Chi^2 vs. the value of the slope and intercept
% parameters.
%
function chisqPlot(experiment, chi_sq, slope_grid, int_grid, chi_grid, slope_range, int_range, fig)

    % -------- Plot Chi^2 vs. slope and intercept as colormap -------------
    figure(fig);
    
    % Surface plot
    ax = axes('Parent',fig);
    h = surf(slope_grid,int_grid,chi_grid,'Parent',ax,'edgecolor','none');
    
    hold on;
    
    % Plot a countour line on the surface plot at a value of Chi^2+1
    contour3(slope_grid,int_grid,chi_grid,[(chi_sq+1) (chi_sq+1)], ...
        'ShowText','off', 'LineColor', 'w', 'LineWidth', 1.2, ...
        'HandleVisibility', 'off');
    
    % Rotate figure view so surface plot becomes 2d, plot heatmap
    set(h, 'edgecolor','none');
    view(ax,[0,90]);
    colormap(parula);
    
    % Text formatting for greek Chi
    chisqtext = "\chi^{2}";
    
    % Adding and formatting color bar
    ccb = colorbar;
    ccb.Label.String = chisqtext;
    pos = get(ccb.Label,'Position');
    ccb.Label.Position = [pos(1)*1.3 pos(2) 0]; % Move label outward
    ccb.Label.Rotation = 0; % Rotate label 90°
    ccb.Label.FontSize = 12;
    
    title(sprintf('%s %s %s %s', "     ", experiment, chisqtext, ...
        "vs. Slope and Intercept Parameters (y = ax + b)"));
    xlabel("Slope"); ylabel("Intercept");
    
    xlim(slope_range); ylim(int_range);

end