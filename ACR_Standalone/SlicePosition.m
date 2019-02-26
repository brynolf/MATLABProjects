function Diff = SlicePosition( image, center, rotation )
% The difference in the left and right vertical bars are compared in slice 
% 1 and 11 

% ± number of pixels off center the vertical bars are in the x direction
Xstep = [-1,1].*3;

% Number of pixels off center the vertical bars are in the y direction
Ystep = [1,1].*64;

% The length of the interval 
interval = 60;

slices = [1 11];
% center = round(center);

% Loop over slices
for i = 1:numel(slices)
    
    % Loop over steps
    for j = 1:numel(Xstep)
        
        % Get x and y positions of line crossing the bar, accounting for 
        % phantom rotations
        img = image.matrix(:,:,slices(i));
        xInd = round(sind(rotation).*[Ystep(j)-interval/2:Ystep(j)+interval/2]+center(slices(i),1)+Xstep(j));
        yInd = round(cosd(rotation).*[(center(slices(i),2)-Ystep(j)+interval/2):-1:(center(slices(i),2)-Ystep(j)-interval/2)]);
        
        % Get matrix indices from x and y positions
        loc = sub2ind(size(img),yInd, xInd);
        
        % Get intensityProfile 
        intensityProfile = img(loc);
        
        % Plot pixels extracted for intensity profile.
        %         figure(3),imshow(img,[]),hold on, plot(xInd,yInd,'r.')
        %         figure(11),plot(yInd,intensityProfile)
        
        % Fit intensity profile to logistic function
        initialGuess = [max(intensityProfile)-min(intensityProfile),yInd(round(interval/2)),min(intensityProfile)];
        [fitresult{i,j}, gof{i,j}] = findEdge(yInd,double(intensityProfile),initialGuess);
        
        % Plot result of logistic fit
        %         figure(11),plot(yInd,intensityProfile)
        %         hold on, plot(yInd,fitresult{i,j}(yInd)),hold off

    end
    
    % A positive difference means that the right bar is longer (has a
    % higher value in the fit)
    Diff(i) = (fitresult{i,2}.b-fitresult{i,1}.b).*image.voxelSize(2);
end


