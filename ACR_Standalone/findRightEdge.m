function findRightEdge(x,y)

[xData, yData] = prepareCurveData( x, y );

% Set up fittype and options.
ft = fittype( 'a/(1+exp(-(x-b)))+c', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [0 -Inf 0];
opts.StartPoint = [2000 0.575 100];
opts.Upper = [100000 Inf 200];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );