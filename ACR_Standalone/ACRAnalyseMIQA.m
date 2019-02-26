function results = ACRAnalyseMIQA( img, imgFolder)%, resultConn, columns  )

% Sort images
[T1w, T2w, localizer] = sortReadImages(img);

results = [];

% Add results{i} to table
centerSlice = 1;

T1T2Images = [T1w(:); T2w(:)];
if ~isempty(T1T2Images)
    % Analyse T1 and T2 images, save to database
    for i = 1:numel(T1T2Images)
        results{i}.Folder = imgFolder;
        % Find center and radius
        [center, T1radius, results{i}.Rotation] = findCenterAndRotationOfPhantom2(T1T2Images{i});
        results{i}.CenterX = center(1,centerSlice);
        results{i}.CenterY = center(2,centerSlice);
        
        % Ghosting Ratio slice 5
        results{i}.GhostingRatioSlice5     = ghostingRatio( T1T2Images{i}, 5, center );
        results{i}.GhostingRatioSlice5STD  = ghostingRatioSTD( T1T2Images{i}, 5, center );
        
        % Uniformity measurements
        [results{i}.MaxROIMean,  results{i}.minROIMean,results{i}.PercentUniformityIntegral, ...
            results{i}.GhostingRatio, results{i}.Noise] = ...
            uniformity(T1T2Images{i},center);
        
        % Slice position accuracy
        slicePositionAccuracy = SlicePosition(T1T2Images{i},center,results{i}.Rotation);
        results{i}.SlicePositionAccuracySlice1  = slicePositionAccuracy(1);
        results{i}.SlicePositionAccuracySlice11 = slicePositionAccuracy(2);
        
        % Slice Thickness
        
        results{i}.SliceThickness = sliceThickness2(T1T2Images{i},center,results{i}.Rotation);
        
        % Geometry
        [lengthX(:,i), lengthY(:,i), lengthD1(:,i), lengthD2(:,i)] = geometry(T1T2Images{i}, center);
        results{i}.DiameterXSlice1 = lengthX(1,i);
        results{i}.DiameterYSlice1 = lengthY(1,i);
        results{i}.DiameterDiag1Slice1 = lengthD1(1,i);
        results{i}.DiameterDiag2Slice1 = lengthD2(1,i);
        
        results{i}.DiameterXSlice5 = lengthX(2,i);
        results{i}.DiameterYSlice5 = lengthY(2,i);
        results{i}.DiameterDiag1Slice5 = lengthD1(2,i);
        results{i}.DiameterDiag2Slice5 = lengthD2(2,i);
        
        % High-contrast
        maxVals = measureHighContrast(T1T2Images{i}, center);
        results{i}.UL1Score = maxVals(1,1);
        results{i}.LR1Score = maxVals(2,1);
        results{i}.UL2Score = maxVals(3,1);
        results{i}.LR2Score = maxVals(4,1);
        results{i}.UL3Score = maxVals(5,1);
        results{i}.LR3Score = maxVals(6,1);
        
        % DICOM tag
        results{i}.PatientID = T1T2Images{i}.imagingInfo.PatientID;
        results{i}.AcquisitionTime = T1T2Images{i}.imagingInfo.AcquisitionTime;
        results{i}.AcquisitionDate = T1T2Images{i}.imagingInfo.AcquisitionDate;
        results{i}.StudyTime = T1T2Images{i}.imagingInfo.StudyTime;
        results{i}.ProtocolName = T1T2Images{i}.imagingInfo.ProtocolName;
        results{i}.OperatorName = reformatNames(T1T2Images{i}.imagingInfo.OperatorName);
        results{i}.SeriesDescription = T1T2Images{i}.imagingInfo.SeriesDescription;
        results{i}.SeriesInstanceUID = T1T2Images{i}.imagingInfo.SeriesInstanceUID;
        results{i}.StudyInstanceUID = T1T2Images{i}.imagingInfo.StudyInstanceUID;
        results{i}.EchoTime = T1T2Images{i}.imagingInfo.EchoTime;
        results{i}.RepetitionTime = T1T2Images{i}.imagingInfo.RepetitionTime;
        results{i}.StudyID = uint16(str2num(T1T2Images{i}.imagingInfo.StudyID));
        results{i}.PatientWeight = T1T2Images{i}.imagingInfo.PatientWeight;
        results{i}.PatientPosition = T1T2Images{i}.imagingInfo.PatientPosition;
        results{i}.ImagePosition = T1T2Images{i}.imagingInfo.ImagePosition;
        results{i}.ReceiveCoilName = T1T2Images{i}.imagingInfo.ReceiveCoilName;
        results{i}.ActualReceiveGainAnalog = T1T2Images{i}.imagingInfo.ActualReceiveGainAnalog;
        results{i}.ActualReceiveGainDigital = T1T2Images{i}.imagingInfo.ActualReceiveGainDigital;
        results{i}.AutoPrescanCenterFrequency = T1T2Images{i}.imagingInfo.AutoPrescanCenterFrequency;
        results{i}.AutoPrescanTransmitGain = T1T2Images{i}.imagingInfo.AutoPrescanTransmitGain;
        results{i}.AutoPrescanAnalogReceiverGain = T1T2Images{i}.imagingInfo.AutoPrescanAnalogReceiverGain;
        results{i}.AutoPrescanDigitalReceiverGain = T1T2Images{i}.imagingInfo.AutoPrescanDigitalReceiverGain;
        results{i}.TransmittingCoilType = T1T2Images{i}.imagingInfo.TransmittingCoilType;
        results{i}.SurfaceCoilType = T1T2Images{i}.imagingInfo.SurfaceCoilType;
        results{i}.PrescanType = T1T2Images{i}.imagingInfo.PrescanType;
        results{i}.TransmitGain = T1T2Images{i}.imagingInfo.TransmitGain;
        results{i}.DB_dtPeakRateOfChangeOfGradientField = T1T2Images{i}.imagingInfo.DB_dtPeakRateOfChangeOfGradientField;
        results{i}.GECoilName = T1T2Images{i}.imagingInfo.GECoilName;
        results{i}.ImagingFrequency =  T1T2Images{i}.imagingInfo.ImagingFrequency;
        results{i}.PixelBandwidth = T1T2Images{i}.imagingInfo.PixelBandwidth;
        results{i}.ImagePosition = fixNumericalTags(T1T2Images{i}.position);
        results{i}.Manufacturer = T1T2Images{i}.imagingInfo.Manufacturer;
        results{i}.ManufacturerModelName = T1T2Images{i}.imagingInfo.ManufacturerModelName;
        results{i}.SoftwareVersion = insertBackslashBetweenCells(T1T2Images{i}.imagingInfo.SoftwareVersion);
        results{i}.DeviceSerialNumber = T1T2Images{i}.imagingInfo.DeviceSerialNumber;
        
    end
else
    warning(sprintf('No valid T1 or T2 weighted images in folder %s',imgFolder))
end

