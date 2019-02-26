function sliceThickness = sliceThickness( image,center )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

slice = 1;
image = image.matrix(:,:,slice);

intervall = 60;
center = round(center);

% Hitta rampen och mäta FWHM (ska bara göras i slice 1)

profilePerpToRamps = abs(diff(image(110:145,128)));

% % Find peaks in profile
% [~, index] = sort(profilePerpToRamps,'descend');
% upperIndex = min(index(1:2));
% lowerIndex = max(index(1:2));

index = find(profilePerpToRamps>(0.14.*image(center(1)-20,center(2))));

for i = 3:3
    Ytop(i,:) = image(index(1) + 110+i+1, (center(1,slice)-intervall):(center(1,slice)+intervall),1);
    Ybtm(i,:) = image(index(end) + 110-i-2, (center(1,slice)-intervall):(center(1,slice)+intervall),1);
end

% 
% figure(1), 
% subplot(1,2,1), plot(Ytop','r')
% hold on
% subplot(1,2,1), plot(Ybtm','b')
% hold off
% subplot(1,2,2), plot(mean(Ytop),'r'),
% hold on, subplot(1,2,2), plot(mean(Ybtm),'b')
% hold off
% figure(2),imshow(image,[]);
% hold on
% for i = 3:3
% %     row1 = upperIndex+110+i+1;
% %     row2 = lowerIndex+110-i-2;
%     row1 = index(1)+110+i+1;
%     row2 = index(end)+110-i-2;
%     plot([1 256],(row1).*[1 1],'r'); 
%     plot([1 256],(row2).*[1 1],'b');
% end
% hold off
% Find all pixels larger than FWHM of mean of top an bottom
indextop = find(mean(Ytop) > (max(mean(Ytop)) + max(mean(Ybtm)))/4);
indexbtm = find(mean(Ybtm) > (max(mean(Ytop)) + max(mean(Ybtm)))/4);


Ltop = (indextop(end)-indextop(1))*0.0977;   %[cm]
Lbtm = (indexbtm(end)-indexbtm(1))*0.0977;

sliceThickness = 10*.2*(Ltop*Lbtm)/(Ltop+Lbtm); % [mm]

end

