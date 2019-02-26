% Folder: 
folder = 'Z:\MRTransfer\_Patients\123456789012\20150409\MR\1';

% Set Matrix4D to read files to cell arrays, to enable reading multiple
% series from the same folder
s               = Matrix4D.getDefaultImportSettings('dicom');
s.outputType    = 'cellArray';
s.splitTags     = {'SeriesInstanceUID', 'EchoTime', 'ImageOrientation'};

% Read image
img     = Matrix4D.import(folder,'dicom',s);

% Sort images
[T1w, T2w, localizer] = sortReadImages( img );
T1T2Images = [T1w(:); T2w(:)];

centerSlice = 1;

% Find center and radius
[center, T1radius, results.Rotation] = findCenterAndRotationOfPhantom(T1T2Images{1});
results.CenterX = center(1,centerSlice);
results.CenterY = center(2,centerSlice);

% Get LCRROIs
slice = 8;
[circleROI, encBckgrndROI,currentPhantomCoords, encROIRadius, currentencROIPos, radius ] = getLCRROIs( T1T2Images{1}, center, results.Rotation, slice );

hold off, figure(111),imagesc(double(T1T2Images{1}.matrix(:,:,slice)),[3200 4400]); colormap gray
axis equal, axis off, hold on
hold off, figure(112),imagesc(conv2(double(T1T2Images{1}.matrix(:,:,slice)),1/9.*ones(3),'same'),[3200 4400]); colormap gray
axis equal, axis off, hold on
hold off, figure(111),imagesc(medfilt2(double(T1T2Images{1}.matrix(:,:,slice)),[3 3]),[3200 4400]); colormap gray
axis equal, axis off, hold on
hold off, figure(112),imagesc(conv2(double(T1T2Images{1}.matrix(:,:,slice)),1/9.*ones(3),'same'),[3200 4400]); colormap gray
axis equal, axis off, hold on
plot(currentPhantomCoords(:,1),currentPhantomCoords(:,2),'b+')
viscircles(currentPhantomCoords,radius,'EdgeColor','b')

