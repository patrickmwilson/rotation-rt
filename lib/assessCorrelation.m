function [slope, intercept, R, reduced_chi_sq] = assessCorrelation(xdata, ydata)

    % Extract x & y values from data matrix
    xvals = xdata(:,1)'; yvals = ydata(:,1)';
    
    % Variance is estimated as the standard error, then squared
    variance = (xdata(:,2) + ydata(:,2))./2;
    variance = variance';
    variance = variance.^2;
    
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
    approx = polyfit(xvals, yvals, 1);
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
    
    R = corr2(xdata(:,1),ydata(:,1));

end