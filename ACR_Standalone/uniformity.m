function [maxROIMean,minROIMean,PUI,GR,noise] = uniformity(T1w, center)
%%
slice = 7;

image = double(T1w.matrix(:,:,slice));

% Create mask of total phantom
maskCenter = [center(slice,1),center(slice,2)]; maskRadius = 75;
totalMask = createCircularMask(image,maskCenter,maskRadius);
maskedPhantom = image.*totalMask;

% Filter phantom to reduce sensitivity to spikes when finding region with
% maximum/minimum signal
filter = double(ones(3,3).*(1/9));
filteredPhantom = conv2(image, filter, 'same');
maskedFilteredPhantom = filteredPhantom.*totalMask;

%% Create smaller ROI for min and max regions

% Find region with maximum signal
[~, index] = max(maskedFilteredPhantom(:));
[maxYcoord,maxXcoord] = ind2sub([256 256],index);

% Find region with minimum signal
[minRow,minCol, v] = find(maskedFilteredPhantom);
[~, ind] = min(v);

% Create smaller ROI for max region
maskCenter = [maxYcoord,maxXcoord]; maskRadius = 6;
maxMask = createCircularMask(image,maskCenter,maskRadius);

% Calculate mean signal in ROI over max region
[~,~,maxValues] = find(maxMask.*image);
maxROIMean = sum(maxValues)./numel(maxValues);

% Create smaller ROI for min region
maskCenter = [minCol(ind),minRow(ind)]; maskRadius = 6;
minMask = createCircularMask(image,maskCenter,maskRadius);

% Calculate mean signal in ROI over union of min region and total mask
[~,~,minValues] = find(image.*minMask.*totalMask);
minROIMean = sum(minValues)./numel(minValues);

% % Create smaller ROI for noise region
% maskCenter = [29,29]; maskRadius = 15;
% noiseMask = createCircularMask(image,maskCenter,maskRadius);
% 
% [~,~,noiseValues] = find(noiseMask.*image);
% noise = std(noiseValues);

% PUI
% % Vet inte om min är riktigt korrekt, lägre än egen mätning
% % Ska va större eller lika med 82%
PUI = 100*(1-(maxROIMean-minROIMean)/(maxROIMean+minROIMean)); % [%]

% Create rectangular ROIs for ghosting measurements and SNR
xSize = 256; ySize = 256; ROILength = 8;ROIWidth = 125;
UpperUL  = [12 66];
LowerUL  = [238 66];
LeftUL   = [66 236];
RightUL  = [66 12];

UpperROI = false(xSize,ySize);
UpperROI(UpperUL(1):(UpperUL(1) + ROILength),UpperUL(2):(UpperUL(2) + ROIWidth)) = true;

LowerROI = false(xSize,ySize);
LowerROI(LowerUL(1):(LowerUL(1) + ROILength),LowerUL(2):(LowerUL(2) + ROIWidth)) = true;

RightROI = false(xSize,ySize);
RightROI(LeftUL(1):(LeftUL(1) + ROIWidth),LeftUL(2):(LeftUL(2) + ROILength)) = true;

LeftROI = false(xSize,ySize);
LeftROI(RightUL(1):(RightUL(1) + ROIWidth),RightUL(2):(RightUL(2) + ROILength)) = true;


L = sum(image(LeftROI))./sum(LeftROI(:));
R = sum(image(RightROI))./sum(LeftROI(:));
U = sum(image(UpperROI))./sum(LeftROI(:));
D = sum(image(LowerROI))./sum(LeftROI(:));

noise = std([image(LowerROI); image(UpperROI)]);
GR = abs( ((U + D) - (L + R))./( 2*sum(maskedPhantom(:))./(sum(totalMask(:))) ));

end
