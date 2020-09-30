% pointSlope
%
% Creates a scatterplot with a regression line. Accepts a data matrix, fit
% parameters, protocol name, color, the error bar direction, and a figure
% handle as input arguments. Scatters the data, the first column as x
% values and the second as y values.
function pointSlope(data,params,color,fig)

    figure(fig);
    
    % Extract slope and intercept values from the params array, set the
    % legend text based upon whether or not an intercept was given
    if length(params) == 1
        slope = params(1);
        intercept = 0;
        txt = "y = %4.3fx";
    else
        slope = params(1);
        intercept = params(2);
        if intercept > 0
            txt = "y = %4.3fx + %4.3f";
        else
            txt = "y = %4.3fx %4.3f";
        end
    end
    
    xfit = linspace((min(data(:,1))*0.99), (max(data(:,1))*1.01));
    
    yfit = (xfit*slope)+intercept;
    
    % Plot error bars
    hold on;

    errorbar(data(:,1), data(:,2), data(:,3), 'vertical','.', ...
        'HandleVisibility', 'off', 'Color', [0.43 0.43 0.43], ...
        'CapSize', 0);
    
    % Plot fit line
    if intercept == 0
        plot(xfit, yfit, 'Color', color, 'LineWidth', 1, 'DisplayName', ...
            sprintf(txt, slope));
    else
        plot(xfit, yfit, 'Color', color, 'LineWidth', 1, 'DisplayName', ...
            sprintf(txt, slope, intercept));
    end
    
    % Scatter data
    scatter(data(:,1), data(:,2), 30, color, 'filled', ...
        'HandleVisibility','off');
end