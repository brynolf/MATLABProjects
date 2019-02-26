function [lineProfile, xInd, yInd, x, y] = getLineProfileFromCoordinates(image, startPoint, stopPoint)

% Calculate the number of points
nPoints = ceil(sqrt((stopPoint(1) - startPoint(1)).^2 + (stopPoint(2) - startPoint(2)).^2)) + 1;

% Generate coordinates
x = linspace(startPoint(1), stopPoint(1), nPoints);
y = linspace(startPoint(2), stopPoint(2), nPoints);
xInd = round(x);
yInd = round(y);

% Extract line profiles
lineProfile     = double(image(sub2ind(size(image), yInd, xInd)));