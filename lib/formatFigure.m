function formatFigure(fig, title_text, x_label, y_label, x_lim, y_lim)

    figure(fig);
    
    xlabel(x_label);
    ylabel(y_label);
    
    title(title_text);
    
    xlim(x_lim);
    ylim(y_lim);
    
    legend('show', 'Location', 'best');
end