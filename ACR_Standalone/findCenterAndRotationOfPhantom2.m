function [center, radius, rotation] = findCenterAndRotationOfPhantom2(img)

% Load image
image = img.matrix;

% Initialize variables
center = zeros(11,2);
radius = zeros(11,1);

%% Find center of phantom
% Expected radius in mm. Diameter = 190 mm
radiusInterval  = 15; % 190 mm ± interval
radInt          = round((95 + [-1, 1]*radiusInterval).*img.voxelSize(1));

% Loop over all slices
for slice = 1:11
    try 
        [center(slice,:), radius(slice)] = imfindcircles(image(:,:,slice),radInt,'Sensitivity',0.90);
        0;
    catch % If no circles are found, use circle from previous slice
        center(slice,:) = center(:,slice-1);
        radius(slice)   = radius(slice-1);
    end
end

%% Find rotation of phantom
% Find rotation by first locating the circle in the upper left qudrant in 
% the first slice of the phantom. 
slice = 1;
image = img.matrix(:,:,slice);
% Threshold the image using the otsu method with 256 bins
[counts,~] = imhist(image,256);
T = otsuthresh(counts);
BW = imbinarize(image,T);

% Invert the binary mask to find the the larger edge of the circle
BW = ~BW;

% Find center of circle
[c,r] = imfindcircles(BW,[16 24]);

% If multiple circles are found for some reason, select the one ~65 mm from
% the center of the phantom
preferredCenterDist = 65; %mm
pCD = preferredCenterDist./img.voxelSize(1);
[~,ind] = min(abs(sqrt(sum((center(slice,:)-c).^2,2)) - pCD));

figure(1), hold off, imshow(image,[]),hold on, 
viscircles(c(ind,:),r(ind));

% The angle should be ~42.5 degrees
roughRotation = atan2d(center(slice,1)-c(ind,1),center(slice,2)-c(ind,2)) - 42.5;

% Now, find the rotation by measuring the location of the upper edge of the 
% horisontal bar at two positions
horizCrossingDistance   = 82; % mm
vertCrossingDistance    = 16; % mm
startPointOffset        = -2;  % mm

hCD = horizCrossingDistance./img.voxelSize(1);
vCD = vertCrossingDistance./img.voxelSize(1);
cO = startPointOffset./img.voxelSize(1);

% Find line crossing of the black bar by fitting to a logistic function
for lp = 1:2
    % Define start and stop points for line profile
    startPoint(lp,:)  = center(slice,:) -  cO.*[-sind(roughRotation), cosd(roughRotation)] + (-1)^(lp).*hCD.*[cosd(roughRotation), sind(roughRotation)];
    stopPoint(lp,:)   = startPoint(lp,:)  - vCD.*[-sind(roughRotation), cosd(roughRotation)];
    
    % Get line profile
    lineProfile = getLineProfileFromCoordinates(image, startPoint(lp,:), stopPoint(lp,:));
    
    % Fit intensity profile to logistic function
    initialGuess = [max(lineProfile)-min(lineProfile),numel(lineProfile)/2,min(lineProfile)];
    [fitResult{lp}, gof{lp}] = findEdge(1:numel(lineProfile),double(lineProfile),initialGuess);
    
    % Plot result of logistic fit
    figure(11); plot(1:numel(lineProfile),lineProfile);
    hold on, plot(1:numel(lineProfile),fitResult{lp}(1:numel(lineProfile))); hold off
    0;
end

correctionAngle = atan2d(fitResult{1}.b-fitResult{2}.b,2*hCD+1);

rotation = roughRotation + correctionAngle;

0;

% Control




