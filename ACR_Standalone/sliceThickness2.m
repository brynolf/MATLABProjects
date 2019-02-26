function result = sliceThickness2(image, center, rotation)

% Only first slice of image used
slice   = 1;
img     = image.matrix(:,:,slice);

%% Place ROIs over the two ramps 
roiWidth = 20; % mm
roiHeight= 3;  % mm
lineWidth= 70; % mm
offsetFromCenter = 1;  % mm
lineProfileOffset = 2; % mm

% Convert distances to pixels
rW = round(roiWidth./image.voxelSize(2));
rH = round(roiHeight./image.voxelSize(1));
cO = round(offsetFromCenter./image.voxelSize(1));
lPO= round(lineProfileOffset./image.voxelSize(1));
lW = round(lineWidth./image.voxelSize(2));
marker = {'b-','r-'};
% rotation = 3
figure(1),imshow(img,[])

% Get line profiles over both ramps to find the center of the signal ramp
% Loop over both ramps
for ramp = 1:2
    
    % Define (x,y) of endpoints
    lineProfileLeft(ramp,:)   = center(slice,:) - lPO.*[sind(rotation).*(-1)^(ramp), cosd(rotation).*(-1)^(ramp+1)] - lW.*[cosd(rotation), sind(rotation)];
    lineProfileRight(ramp,:)  = center(slice,:) - lPO.*[sind(rotation).*(-1)^(ramp), cosd(rotation).*(-1)^(ramp+1)] + lW.*[cosd(rotation), sind(rotation)];
    
    figure(1); hold on; plot([lineProfileLeft(ramp,1) lineProfileRight(ramp,1)],[lineProfileLeft(ramp,2) lineProfileRight(ramp,2)],'r-')
    
    % Get line profile from coordinates
    [lineProfile(:,ramp), xInd(:,ramp), yInd(:,ramp), x(:,ramp), y(:,ramp)] = getLineProfileFromCoordinates(img,lineProfileLeft(ramp,:),lineProfileRight(ramp,:));
    
    % Fit gaussian to ramp, find center, FWHM
    initialGuess = double([max(lineProfile(:,ramp))-min(lineProfile(:,ramp)),numel(lineProfile(:,ramp))/2,15,min(lineProfile(:,ramp))]);
    [fitResult{ramp}, gof{ramp}] = fitToGaussian(lineProfile(:,ramp),initialGuess);
    
    % Set ROI width to FWHM of gaussian fit
    rW(ramp) = fitResult{ramp}.s .* 2 .* sqrt(2*log(2));
end
win = (fitResult{ramp}.a-fitResult{ramp}.b)/2+fitResult{ramp}.b;
figure(2),imshow(img,[win-1,win]), hold on, 
plot([lineProfileLeft(ramp,1) lineProfileRight(ramp,1)],[lineProfileLeft(ramp,2) lineProfileRight(ramp,2)],'r-')

xSign = [-1, -1, 1, 1, -1];
ySign = [-1, 1, 1, -1, -1];

% Create ROIs centered over each ramp, with the width of the FWHM
for ramp = 1:2
    
    roiW = rW(ramp):3*rW(ramp);
    for roiWidth = 1:numel(roiW)
    
        diagAngleROI = atand(rH/roiW(roiWidth));
        diagL = sqrt(rH.^2 + roiW(roiWidth).^2);
        for corner = 1:5
            ROI(corner,:,ramp)   = [x(round(fitResult{ramp}.c),ramp), y(round(fitResult{ramp}.c),ramp)] + ...
                (1/2) .* [xSign(corner).*diagL.*cosd(diagAngleROI+(-1)^(corner+1)*rotation), ySign(corner).*diagL.*sind(diagAngleROI+(-1)^(corner+1)*rotation)];
        end
        figure(2), hold on, plot(ROI(:,1,ramp),ROI(:,2,ramp),marker{ramp})
        mask(:,:,ramp) = poly2mask(ROI(:,1,ramp), ROI(:,2,ramp),size(image.matrix,1),size(image.matrix,2));
        threshCount(roiWidth, ramp)   = numel(img(img > win & mask(:,:,ramp)));
        maskCount(roiWidth, ramp) = numel(find(mask(:,:,ramp)));
        figure(10), plot(maskCount(1:roiWidth,:),threshCount(1:roiWidth,:))
        figure(11), plot(maskCount(1:roiWidth,:),maskCount(1:roiWidth,:)-threshCount(1:roiWidth,:))
%         figure(11), plot(maskCount,diff(threshCount))
        0;
    end
end
0;
%% Find the mean in the ramps
% centerLeft(ramp,:)    = [xInd(round(fitResult{ramp}.c),ramp) yInd(round(fitResult{ramp}.c),ramp)] - rW.*[cosd(rotation), sind(rotation)];%  - cO.*[sind(rotation).*(-1)^(ramp), cosd(rotation).*(-1)^(ramp+1)];
%     centerRight(ramp,:)   = [xInd(round(fitResult{ramp}.c),ramp) yInd(round(fitResult{ramp}.c),ramp)] + rW.*[cosd(rotation), sind(rotation)];%  - cO.*[sind(rotation).*(-1)^(ramp), cosd(rotation).*(-1)^(ramp+1)];
%     distantLeft(ramp,:)   = centerLeft(ramp,:) - rH.*[(-1)^(ramp).*sind(rotation), (-1)^(ramp+1).* cosd(rotation)];
%     distantRight(ramp,:)  = centerRight(ramp,:)- rH.*[(-1)^(ramp).*sind(rotation), (-1)^(ramp+1).* cosd(rotation)];