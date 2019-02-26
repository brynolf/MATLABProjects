function [T1w, T2w, localizer] = sortReadImages( img )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Sort read images into output variables
T1w = {};
T2w = {};
localizer = {};
% Loop over all images
for i = 1:numel(img)
%     datestr(img{i}(1).timeStamp(1)./86400,'mmdd')
    
    % T2w image
    if sum(size(img{i}) == [1 2]) == 2
        % Find number of rows in T2w
        newRow = size(T2w,1) + 1;
        for j = 1:2
            if numel(size(img{i}(j).matrix)) == 3 && sum(size(img{i}(j).matrix) == [256 256 11]) == 3 && img{i}(j).imagingInfo.EchoTime == 20 && round(img{i}(j).imagingInfo.RepetitionTime) == 2000
                tmp = img{i}(j);
                tmp.matrix = fliplr(rot90(tmp.matrix,3));
                T2w{newRow,1} = tmp;
            elseif numel(size(img{i}(j).matrix)) == 3 && sum(size(img{i}(j).matrix) == [256 256 11]) == 3 && img{i}(j).imagingInfo.EchoTime == 80 && round(img{i}(j).imagingInfo.RepetitionTime) == 2000
                tmp = img{i}(j);
                tmp.matrix = fliplr(rot90(tmp.matrix,3));
                T2w{newRow,2} = tmp;
            end
        end
%         disp('ACR Axial T2 double-echo');
        
         % T1w image
    elseif numel(size(img{i}.matrix)) == 3 && sum(size(img{i}) == [1 1]) == 2 && sum(size(img{i}.matrix) == [256 256 11]) == 3 && round(img{i}.imagingInfo.RepetitionTime) == 500
            newRow = size(T1w,1) + 1;
            tmp = img{i};
            tmp.matrix = fliplr(rot90(tmp.matrix,3));
            T1w{newRow,1} = tmp;
%             disp('ACR Axial T1');

    elseif numel(size(img{i}.matrix)) == 2 &&  sum(size(img{i}.matrix) == [256 256]) == 2 && round(img{i}.imagingInfo.RepetitionTime) == 200
            newRow = size(localizer,1) + 1;
            localizer{newRow,1} = img{i};
%             disp('ACR Sagittal locator');
            
    end
end

end

