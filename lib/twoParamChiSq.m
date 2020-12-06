% twoParamChiSq
%
% Optimizes the slope and intercept parameters of the y = ax + b fit to 
% minimize Chi^2. Plots Chi^2 vs. slope and intercept parameters as both a
% surface plot and colormap. Takes the data matrix, name, id, color of the 
% protocol, the parameter output struct, and a figure handle as input 
% arguments.
function [params, paramOutput] = twoParamChiSq(data,name,approx,side,paramOutput,chiSqPlot)
    
    % Extract x & y values from data matrix
    xvals = data(:,1)'; yvals = data(:,2)';
    
    % Variance is estimated as the standard error, then squared
    variance = (data(:,3)').^2;
    
    % Slight data shift to avoid division by zero
    variance(variance == 0) = 0.000001;
    
    % Weights are the inverse of (standard error)^2
    w = 1./variance;
    
    % Chi^2 function to be minimized
    f = @(x,xvals,yvals,w)sum(w.*((yvals-((xvals.*x(1))+x(2))).^2));
    fun = @(x)f(x,xvals,yvals,w);
    
    % MultiStart with the fmincon algorithm and 50 start points used to
    % locate a global minimum of the Chi^2 function. 
    ms = MultiStart;
    approxSlope = approx(1); approxInt = approx(2);
    
    problem = createOptimProblem('fmincon','x0',approx, ...
        'objective',fun, ...
        'lb', [(approxSlope-10), (approxInt-100)],...
        'ub',[(approxSlope+10), (approxInt+100)]);
    
    params = run(ms,problem,50);
    chi_sq = fun(params);
    
    slope = params(1);
    intercept = params(2);
    
    % Reduced Chi^2 = Chi^2/(Degrees of Freedom)
    reduced_chi_sq = chi_sq/(length(xvals)-2);
    disp(reduced_chi_sq);
    
    % Storing parameters in output struct
    paramOutput.(strcat(name, '_', side, '_slope')) = slope;
    paramOutput.(strcat(name, '_', side, '_intercept')) = intercept;
    paramOutput.(strcat(name, '_', side, '_chi_sq')) = chi_sq;
    paramOutput.(strcat(name, '_', side, '_reduced_chi_sq')) = reduced_chi_sq;
    
    % The standard error of the parameters is estimated as the parameter
    % value in both the + and - directions which results in a Chi^2 of + 1,
    % with the other parameter held constant (at its minimum value). 
    % fminbnd used to optimize this parameter, and the results are saved to 
    % the output struct
    target = chi_sq+1;
    f = @(x,intercept,xvals,yvals,w)abs(target-sum(w.*((yvals-((xvals.*x)+intercept)).^2)));
    
    % Targeting slope parameter
    fun = @(x)f(x,intercept,xvals,yvals,w);
    negSlopeError = fminbnd(fun,(slope-abs(slope*0.5)),slope);
    posSlopeError = fminbnd(fun,slope,(slope+abs(slope*1.5)));
    
    % Targeting intercept parameter
    f = @(slope,intercept,xvals,yvals,w)abs(target-sum(w.*((yvals-((xvals.*slope)+intercept)).^2)));
    fun = @(intercept)f(slope,intercept,xvals,yvals,w);
    negInterceptError = fminbnd(fun,(intercept-abs(intercept*0.1)),intercept);
    posInterceptError = fminbnd(fun,intercept,(intercept+abs(intercept*0.1)));
    
    f = @(slope,intercept,xvals,yvals,w)sum(w.*((yvals-((xvals.*slope)+intercept)).^2));
    fun = @(slope,intercept)f(slope,intercept,xvals,yvals,w);

    % Initial range of slope and intercept values for the figures
    slope_range = [negSlopeError posSlopeError];
    int_range = [negInterceptError posInterceptError];
    
    
    % Generate a grid of slope, intercept, and Chi^2 values to be plotted
    complete = false;
    while(~complete)
        % Generate the grids
        [slope_grid, int_grid] = meshgrid(...
            linspace(slope_range(1), slope_range(2)), ...
            linspace(int_range(1), int_range(2)));
        chi_grid = cellfun(fun, num2cell(slope_grid), num2cell(int_grid));
        
        % Check the grid to ensure that the edges of the Chi^2 grid are all
        % greater than the minimum + 4
        [slope_range,int_range,complete] = checkGrid(chi_grid, ...
            slope_range, int_range, (chi_sq+4));
    end
    
    chisqPlot(name, chi_sq, slope_grid, int_grid, chi_grid,...
        slope_range, int_range, chiSqPlot);
    
    negSlopeError = slope - negSlopeError;
    posSlopeError = posSlopeError - slope;
    
    paramOutput.(strcat(name, '_', side, '_slope_neg_error')) = negSlopeError;
    paramOutput.(strcat(name, '_', side, '_slope_pos_error')) = posSlopeError;
    
    negInterceptError = intercept - negInterceptError;
    posInterceptError = posInterceptError - intercept;
    
    paramOutput.(strcat(name, '_', side, '_intercept_neg_error')) = negInterceptError;
    paramOutput.(strcat(name, '_', side, '_intercept_pos_error')) = posInterceptError;

end