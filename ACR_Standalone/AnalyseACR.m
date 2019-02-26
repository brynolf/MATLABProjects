function results = AnalyseACR(folder)
% Set Matrix4D to read files to cell arrays, to enable reading multiple
% series from the same folder
s               = Matrix4D.getDefaultImportSettings('dicom');
s.outputType    = 'cellArray';
s.splitTags     = {'SeriesInstanceUID', 'EchoTime', 'ImageOrientation'};

% Read image
img     = Matrix4D.import(folder,'dicom',s);

results = ACRAnalyseMIQA( img, folder );