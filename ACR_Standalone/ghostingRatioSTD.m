function GR  = ghostingRatioSTD( img, slice, center )

GR = NaN(1,numel(slice));
for i = 1:numel(slice)
    image = double(img.matrix(:,:,slice(i)));
    
    % Create mask of total phantom
    maskCenter = [center(slice(i),1),center(slice(i),2)]; maskRadius = 75;
    totalMask = createCircularMask(image,maskCenter,maskRadius);
    maskedPhantom = image(totalMask);
    
    % Create rectangular ROIs for ghosting measurements and SNR
    % Change to coordinates relative to phantom
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
    
    L2 = std(image(LeftROI));
    R2 = std(image(RightROI));
    U2 = std(image(UpperROI));
    D2 = std(image(LowerROI));
    
    GR(i) = abs( ((U2 + D2) - (L2 + R2)));
end
