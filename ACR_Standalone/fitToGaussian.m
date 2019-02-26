function [fitResult, gof] = fitToGaussian(y, initialGuess)
%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( [], y );

% Set up fittype and options.
ft = fittype( 'a.*exp(-((x-c)/(2*s))^2)+b', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [0 0 0 0];
opts.StartPoint = initialGuess; %[400 90 90 300];

% Fit model to data.
[fitResult, gof] = fit( xData, yData, ft, opts );