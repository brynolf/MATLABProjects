function maxVals = measureHighContrastNew(T1w, centerT1w)

%% Settings
% High-contrast spatial resolution, Slice 1 alla bilder
RelCoord(:,1) = [-31; 24];
RelCoord(:,2) = [-38; 17];
RelCoord(:,3) = [-31; 00];
RelCoord(:,4) = [-39; -7];
RelCoord(:,5) = [-31; -24];
RelCoord(:,6) = [-37; -30];


SquareSize = [11;11];
image = T1w.matrix(:,:,1);

normalizationPoint = centerT1w(:,1)+[0;-15];

threshold = -150;
minPeakHeight = image(round(normalizationPoint(2)),round(normalizationPoint(1)),1)./5;
maxVals = zeros(6,2);
%% Calculations
for s = 1:6
    % Extract the three different squares
    ULindex = round([centerT1w(2:-1:1,1)-RelCoord(:,s)]);
    LRindex = round([centerT1w(2:-1:1,1)-RelCoord(:,s) + SquareSize]);
    square = image(ULindex(1):LRindex(1),ULindex(2):LRindex(2));
    
%     figure(6),imshow(image,[]); hold on,
%     plot(centerT1w(1),centerT1w(2),'bo');
%     plot(ULindex(2),ULindex(1),'bo');
%     figure(5),imagesc(image(ULindex(1):LRindex(1),ULindex(2):LRindex(2))), colormap gray, hold on
%     0;
    
    for i = 1:(SquareSize(1)+1)
        
        % Look in rows and columns
        if isodd(s) 
            sliceProfile = square(i,:);
        else
            sliceProfile = square(:,i);
        end
        
        diffSliceProfile = diff(sliceProfile);
        peaks = find((diffSliceProfile)<threshold & sliceProfile(1:end-1)>minPeakHeight);
        
%         if isodd(s) 
%             plot(peaks,ones(size(peaks)).*i,'bo');
%         else
%             plot(ones(size(peaks)).*i,peaks,'bo');
%         end
%         
        nPeaks = numel(peaks) - numel(find(diff(peaks)==1));
        
        if maxVals(s,1) < nPeaks && nPeaks < 5
            maxVals(s,1) = nPeaks;
            % Save the y-coordinate of the row with the maximum score
            maxVals(s,2) = round((i-1) + centerT1w(2) - RelCoord(1,s));
        end
    end
    
end

end
