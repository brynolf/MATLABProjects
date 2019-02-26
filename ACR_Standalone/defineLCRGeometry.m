function defineLCRGeometry(img,center,rotation,counter)
% Coordinates found in T1w{1,1}

image = double(img.matrix(:,:,11));

coord = [   146 102;
            140 114;
            134 125.5;
            
            163 119;
            151.5 125;
            140 131;
            
            167 143;
            154.5 141;
            141.5 139;
            
            156.5 164.5;
            147 155.5;
            138 146.5;
            
            135 176;
            133 163;
            130.5 150;
            
            111 172;
            117 160.5;
            122.5 149;
            
            094 155.5;
            105.5 149.5;
            117 143;
            
            090 131.5;
            103 133.5;
            115.5 135.5;
            
            100.5 109.5;
            110 119;
            119 128;
            
            122 98.5;
            124.5 111.5;
            126 124];         
        
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
centerCoords = bsxfun(@minus,coord, [129.0292 128.4693]);

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

%% Define background ROI for each circle
% Calc polar coordinates, relative to phantom center

% currentCircleCenter = circleCenter + (center(:,11)-[129.0292 128.4693]');
[theta, rho] = cart2pol(currentPhantomCoords(:,1)-currentCircleCenter(1),currentPhantomCoords(:,2)-currentCircleCenter(2));

% Rotate ROIs by 18 degrees cw
theta = theta + 18*pi/180;

% Convert to cartesian coordinates again
[bckgrndX, bckgrndY] = pol2cart(theta,rho.*0.95);

% Add phantom center coordinate
bckgrndX = bckgrndX + currentCircleCenter(1);
bckgrndY = bckgrndY + currentCircleCenter(2);

% Add circle in middle to act as background for inner circles
bckgrndX(3:3:end,:) = currentCircleCenter(1);
bckgrndY(3:3:end,:) = currentCircleCenter(2);

circleROI = false([size(image) numel(bckgrndX)]);
bckgrndROI= circleROI;

bckgrndROIRadius = repmat([3.5;3.5;6],10,1);

%%
% Create ROI
for i = 1:numel(bckgrndX)
    circleROI(:,:,i) = createCircularMask(image,currentPhantomCoords(i,:),radius(i));
    bckgrndROI(:,:,i) = createCircularMask(image,[bckgrndX(i) bckgrndY(i)],bckgrndROIRadius(i));
end

% %% Create average of neigbour ROIs
% 
% % Create ROI
% for i = 1:numel(bckgrndX)
%     index2 = mod(i-3,30);
%     if index2 == 0
%         index2 = 30;
%     end
%     bckgrndROI2(:,:,i) = createCircularMask(image,[bckgrndX(i) bckgrndY(i)],bckgrndROIRadius(i)) + createCircularMask(image,[bckgrndX(index2) bckgrndY(index2)],bckgrndROIRadius(index2));
%     0;
% end

%% Create encompassing ROI
ROIpos = [145 104];
r = 6;
% viscircles(ROIpos,r,'EdgeColor','g')
encROIPos = zeros(30,2);
encROIRadius = zeros(30,1);

cntr = 0;

% % Outer background ROIs
% for i = 1:3:30
%     [theta, rho] = cart2pol(ROIpos(1)-templateCircleCenter(1),ROIpos(2)-templateCircleCenter(2));
%     
%     % Rotate ROIs by 36 degrees cw
%     theta = theta + cntr.*36.*pi./180;
%     cntr  = cntr + 1;
%     
%     % Convert to cartesian coordinates again
%     [tmpX,tmpY] = pol2cart(theta,rho);
%     encROIPos(i,:) = [tmpX + templateCircleCenter(1),tmpY + templateCircleCenter(2)];
%     
%     encROIRadius(i) = 5;
% end

% Middle background ROIs
for i = 2:3:30
    encROIPos(i,:) = coord(i,:);
    encROIRadius(i) = 8;
end

% Inner background ROIs
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

for i = 1:30
    
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
    else

        tmp = createCircularMask(image,currentencROIPos(i,:),encROIRadius(i)) - circleROI(:,:,i);
        tmp(tmp<0) = 0;
        tmp = logical(tmp);
        encBckgrndROI(:,:,i) = tmp;
    end
end

encBckgrndROI = logical(encBckgrndROI);
%%
% Calculate mean for circleROI and mean and std for bckgrndROI
for i = 1:size(circleROI,3)
    meanROI(i) = mean(image(circleROI(:,:,i)));
    maxROI(i) = max(image(circleROI(:,:,i)));
    prc90ROI(i) = prctile(image(circleROI(:,:,i)),90);
    stdROI(i) = mean(image(circleROI(:,:,i)));
    meanBckgrnd(i) = mean(image(encBckgrndROI(:,:,i)));
    stdBckgrnd(i) = std(image(encBckgrndROI(:,:,i)));
end


%%
% for i = 1:30
%     figure(112),imshow(image.*(1+encBckgrndROI(:,:,i)),[])
%     viscircles(currentPhantomCoords(i,:),radius(i),'EdgeColor','b')
%     pause
% end
hyp = NaN(1,30);
for i = 1:30
    hyp(i) = ttest2(image(encBckgrndROI(:,:,i)),image(circleROI(:,:,i)),'Alpha',0.1);
end

% Check result
% figure(111),imtool(image,[2500 3400],'InitialMagnification',400)
% figure(111),imshow(image,[2500 3400]);
figure(111),imshow(image,[1300 1800])
% viscircles(currentCircleCenter',42,'EdgeColor','m')
% viscircles(currentCircleCenter',35,'EdgeColor','m')
% viscircles(currentencROIPos,encROIRadius,'EdgeColor','g')
% viscircles(currentPhantomCoords,radius,'EdgeColor','b')
% figure,imshow(image,[])
% viscircles([bckgrndX bckgrndY],ones(size(bckgrndX)).*bckgrndROIRadius,'EdgeColor','r')

f1 = find(hyp==0);
if ~isempty(f1)
    scoreHT = floor(f1(1)/3);
    viscircles(currentPhantomCoords(f1,:),radius(f1),'EdgeColor','b')
else
    scoreHT = 10;
end

noiseFactor = 1.010;
% noiseFactor = 1;
% figure(2),plot(meanROI,'-bo'),hold on, plot(meanBckgrnd,'-ro'), plot(meanBckgrnd*noiseFactor,'--ro'),hold off
% f = find(meanROI<meanBckgrnd*noiseFactor);
% if ~isempty(f)
%     scoreNoiseFactor = floor(f(1)/3);
% else
%     scoreNoiseFactor = 10;
% end


tmp2 = (meanBckgrnd +1*stdBckgrnd);
figure(3),plot(meanROI,'-bo'),hold on, plot(meanBckgrnd,'-ro'), plot(tmp2,'--ro'), hold off
f2 = find(meanROI<tmp2);
if ~isempty(f2)
    scoreStd = floor(f2(1)/3);
else
    scoreStd = 10;
end
% 
% 
% fprintf('ScoreNoiseFactor %i  : %i\n',counter,int32(scoreNoiseFactor) );
fprintf('ScoreStd           : %i\n',int32(scoreStd) );
fprintf('ScoreHT           : %i\n',int32(scoreHT) );
0;

