function [center, radius, rotation] = findCenterAndRotationOfPhantom(img)

% Load image
image = img.matrix;

% Initialize variables
center = zeros(2,11);
radius = zeros(1,11);

%% Find center of phantom
% Expected radius in mm. Diameter = 190 mm
radiusInterval  = 15; % 190 mm ± interval
radInt          = round((95 + [-1, 1]*radiusInterval).*img.voxelSize(1));

% Loop over all slices
for j = 1:11
    try 
        [center(:,j), radius(j)] = imfindcircles(image(:,:,j),radInt,'Sensitivity',0.90);
        0;
    catch % If no circles are found, use circle from previous slice
        center(:,j) = center(:,j-1);
        radius(j)   = radius(j-1);
    end
end

%% Find rotation of phantom

deltaY = 40;

diffInY1 = abs(diff(image((round(center(2,1))-deltaY):(round(center(2,1))+deltaY),round(center(1,1))+79,1)));
diffInY2 = abs(diff(image((round(center(2,1))-deltaY):(round(center(2,1))+deltaY),round(center(1,1))-79,1)));

maxVal = max(img.matrix(:));

index1 = find(diffInY1>0.05*maxVal);
index2 = find(diffInY2>0.05*maxVal);

% [~,index1] = max(diffInY1);
% [~,index2] = max(diffInY2);
rotation = atan2(index1(1)-index2(1),2*79+1);