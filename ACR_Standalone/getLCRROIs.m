function [circleROI, encBckgrndROI,currentPhantomCoords, encROIRadius, currentencROIPos, radius ] = getLCRROIs( img, center, rotation, slice )
% Find phantom LCR regions in specific image.
% TODO: Image template with really high SNR to find exact position in
% template, transferrable to any image

%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

image = double(img.matrix(:,:,11));

% coord = [   146 102;
%             140 114;
%             134 125.5;
%             
%             163 119;
%             151.5 125;
%             140 131;
%             
%             167 143;
%             154.5 141;
%             141.5 139;
%             
%             156.5 164.5;
%             147 155.5;
%             138 146.5;
%             
%             135 176;
%             133 163;
%             130.5 150;
%             
%             111 172;
%             117 160.5;
%             122.5 149;
%             
%             094 155.5;
%             105.5 149.5;
%             117 143;
%             
%             090 131.5;
%             103 133.5;
%             115.5 135.5;
%             
%             100.5 109.5;
%             110 119;
%             119 128;
%             
%             122 98.5;
%             124.5 111.5;
%             126 124];         

coord = [145.5 101.5;
    139.5 113;
    134 125;
    
    163 118;
    151.5 124.5;
    139.5 130.5;
    
    167 142.5;
    154 140.25;
    141 138.5;
    
    156 164;
    147 154.75;
    137.25 145.75;
    
    134.5 175;
    132.25 162.25;
    130.25 149.5;
    
    110.5 171.25;
    116.25 160;
    122.25 148.25;
    
    93 154.25;
    104.5 148.5
    116.5 142.5;
    
    89.5 130.5;
    102.5 132.5;
    115 134.25;
    
    100.25 108.75;
    109.5 118;
    118.75 127;
    
    121.5 97.5;
    124 110.5;
    126 123.5];
        
r = [       3.8;
            3.5;
            3.2;
            3;
            2.8;
            2.5;
            2.2;
            2;
            2;
            1.8];
        
radius = reshape(r(:,ones(1,3))',1,numel(r).*3)';


%% transfer coordinates to current phantom

% Make coordinates relative to phantom center of T1w{1,1}
% centerCoords = bsxfun(@minus,coord, [129.0292 128.4693]);
centerCoords = bsxfun(@minus,coord, [128.7285, 127.5922]);

% Add coordiantes of current phantom
currentPhantomCoords = bsxfun(@plus, centerCoords, center(:,11)');

% Add rotation of current phantom
[theta, rho] = cart2pol(currentPhantomCoords(:,1)-center(1),currentPhantomCoords(:,2)-center(2));
[tmpX, tmpY] = pol2cart(theta+rotation,rho);
currentPhantomCoords = [tmpX+center(1), tmpY+center(2)];

%% Find center of template circles by linear regression
for i = 1:5
    ind1 = 3.*(i-1) + 1;
    ind2 = 3.*(i-1) + 16;
    X = [ones(6,1) [coord(ind1:(ind1+2),1);coord((ind2+2):-1:(ind2),1)]];
    Y = [coord(ind1:(ind1+2),2);coord((ind2+2):-1:ind2,2)];
    
    lr(i,:)= lscov(X,Y);
    
end

% Find intersection of the lines
templateCircleCenter = [-lr(:,2) ones(5,1)]\lr(:,1);

%% Find center of current circles by linear regression
for i = 1:5
    ind1 = 3.*(i-1) + 1;
    ind2 = 3.*(i-1) + 16;
    X = [ones(6,1) [currentPhantomCoords(ind1:(ind1+2),1);currentPhantomCoords((ind2+2):-1:(ind2),1)]];
    Y = [currentPhantomCoords(ind1:(ind1+2),2);currentPhantomCoords((ind2+2):-1:ind2,2)];
    
    lr(i,:)= lscov(X,Y);
    
end

% Find intersection of the lines
currentCircleCenter = [-lr(:,2) ones(5,1)]\lr(:,1);

%% Rotate template depending on slice
%Find angle of first row in slice 11. In slice 8 the angle is -pi/2
t11 = atan(lr(1,2));
rot = (-pi/2-t11)/3;

% Add rotation of current phantom
[theta, rho] = cart2pol(currentPhantomCoords(:,1)-currentCircleCenter(1),currentPhantomCoords(:,2)-currentCircleCenter(2));

% Angle depends on slice
if slice == 8
    [tmpX, tmpY] = pol2cart(theta+rot*3,rho);
elseif slice == 9
    [tmpX, tmpY] = pol2cart(theta+rot*2,rho);
elseif slice == 10
    [tmpX, tmpY] = pol2cart(theta+rot*1,rho);
elseif slice == 11
    [tmpX, tmpY] = pol2cart(theta+rot*0,rho);
end

currentPhantomCoords = [tmpX+currentCircleCenter(1), tmpY+currentCircleCenter(2)];

% figure,imshow(img.matrix(:,:,slice),[2000 3900]);
% viscircles(currentPhantomCoords,radius,'EdgeColor','b')
% 0;

%% Create ROIs
circleROI = false(256,256,30);
for i = 1:30
    circleROI(:,:,i) = createCircularMask(image,currentPhantomCoords(i,:),radius(i));
end


%% Create background ROI encompassing the circle ROIs

encROIPos = zeros(30,2);
encROIRadius = zeros(30,1);

% Middle background ROIs, circles encompassing ROIs
for i = 2:3:30
    encROIPos(i,:) = coord(i,:);
    encROIRadius(i) = 8;
end

% Inner background ROIs, circle in the middle.
for i = 3:3:30
    encROIPos(i,:) = templateCircleCenter;
    encROIRadius(i) = 8;
end

% Special case for the smallest inner plupps
encROIPos(30,:) = [125 124];
encROIRadius(30) = 5;

encROIPos(27,:) = coord(27,:);
encROIRadius(27) = 4;

% Convert to current phantom ROI coordinates
centerCoords = bsxfun(@minus,encROIPos, [129.0292 128.4693]);

% Add coordiantes of current phantom
currentencROIPos = bsxfun(@plus, centerCoords, center(:,11)');

% Add rotation of current phantom
[theta, rho] = cart2pol(currentencROIPos(:,1)-center(1),currentencROIPos(:,2)-center(2));
[tmpX, tmpY] = pol2cart(theta+rotation,rho);
currentencROIPos = [tmpX+center(1), tmpY+center(2)];

% Create masks
for i = 1:30
    
    % Outermost ROIs, polygons
    if ~isempty(intersect(1:3:30,i))
        [t, r] = cart2pol(currentPhantomCoords(i,1)-currentCircleCenter(1),currentPhantomCoords(i,2)-currentCircleCenter(2));
        angle = 13;
        
        [x(1),y(1)] = pol2cart(t+angle*pi/180,43);
        [x(2),y(2)] = pol2cart(t-angle*pi/180,43);
        [x(3),y(3)] = pol2cart(t-angle*pi/180,35);
        [x(4),y(4)] = pol2cart(t+angle*pi/180,35);
        [x(5),y(5)] = pol2cart(t+angle*pi/180,43);
        x = x + currentCircleCenter(1);
        y = y + currentCircleCenter(2);
        
        encBckgrndROI(:,:,i) = poly2mask(round(x), round(y), 256, 256) - circleROI(:,:,i);
        
    % Inner ROIs, circles
    else
        
        tmp = createCircularMask(image,currentencROIPos(i,:),encROIRadius(i)) - circleROI(:,:,i);
        tmp(tmp<0) = 0;
        tmp = logical(tmp);
        encBckgrndROI(:,:,i) = tmp;
    end
end

encBckgrndROI = logical(encBckgrndROI);
end

