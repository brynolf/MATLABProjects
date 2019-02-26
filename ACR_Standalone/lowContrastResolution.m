function lowContrastResolution( img, center, rotation, slice )

%% Get ROIs
[circleROI, encBckgrndROI, currentPhantomCoords, encROIRadius, currentencROIPos, radius ] = getLCRROIs( img, center, rotation, slice );
image = double(img.matrix(:,:,slice));

%% Evaluate LCR

hyp1 = NaN(1,30);
hyp2 = NaN(1,30);
for i = 1:30
    hyp1(i) = ttest2(image(circleROI(:,:,i)),image(encBckgrndROI(:,:,i)),'Alpha',0.01);
    hyp2(i) = ranksum(image(encBckgrndROI(:,:,i)),image(circleROI(:,:,i)));
end

f1 = find(hyp1==0);
f2 = find(hyp2>0.10);
% figure(2),imshow(img.matrix(:,:,slice),[1300 1800]);
figure(2),imshow(img.matrix(:,:,slice),[700 1000]);

for i = 1:30
    figure(112),imshow(image.*(1+encBckgrndROI(:,:,i)),[])
    viscircles(currentPhantomCoords(i,:),radius(i),'EdgeColor','b')
    pause
end

viscircles(currentPhantomCoords,radius,'EdgeColor','b')
viscircles(currentencROIPos,encROIRadius,'EdgeColor','c')

% T-test
if ~isempty(f1)
    scoreHT = floor(f1(1)/3);
    viscircles(currentPhantomCoords(f1,:),radius(f1),'EdgeColor','b')
else
    scoreHT = 10;
end

% Wilcoxon
if ~isempty(f2)
    scoreWT = floor(f2(1)/3);
    viscircles(currentPhantomCoords(f2,:),radius(f2),'EdgeColor','g')
else
    scoreWT = 10;
end

fprintf('ScoreHT           : %i\n',int32(scoreHT) );
fprintf('ScoreWT           : %i\n',int32(scoreWT) );
0;
end

