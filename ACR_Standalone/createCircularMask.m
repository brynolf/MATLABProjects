function mask = createCircularMask(refImage,maskCenter,maskRadius)
[xDim,yDim] = size(refImage);
[a, b]=meshgrid(1:xDim,1:yDim);
mask = false(xDim,yDim);
mask(sqrt((a-maskCenter(1)).^2 + (b-maskCenter(2)).^2) < maskRadius) = true;
