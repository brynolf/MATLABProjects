function [lengthX, lengthY, lengthD1, lengthD2] = geometry(image, center)
% Mäta diametern på fatomet. I X och Y rikting samt diagonaler
% Detta ska göras i snitt 1 och 5
% den riktiga diametern är 19cm

image = image.matrix;
center = round(center);
slices = [1 5]';

lengthX = zeros(size(slices));
lengthY = zeros(size(slices));
lengthD1 = zeros(size(slices));
lengthD2 = zeros(size(slices));

for i = 1:numel(slices)
    
    diffInY = abs(diff(image(:,center(2,i),slices(i))));
    diffInX = abs(diff(image(center(1,i),:,slices(i))));
    
    indexD1x = [center(1,i)-100 : center(1,i)-1 center(1,i):center(1,i)+100];
    indexD1y = [center(2,i)-100 : center(2,i)-1 center(2,i):center(2,i)+100];
    indexD2y = [center(2,i)+100 : -1 : center(2,i)+1 center(2,i):-1:center(2,i)-100];
    
    for j = 1:numel(indexD1x)
       dProfile1(j) = image(indexD1x(j),indexD1y(j));  
       dProfile2(j) = image(indexD1x(j),indexD2y(j));  
    end
    
    diffInD1 = abs(diff(dProfile1));
    diffInD2 = abs(diff(dProfile2));
    
    maxVal = max(max(image(:,:,i)));
    
    indexY = find(diffInY > 0.125*maxVal);
    indexX = find(diffInX > 0.125*maxVal);
    indexD1= find(diffInD1 > 0.125*maxVal);
    indexD2= find(diffInD2 > 0.125*maxVal);
    
  
    
    lengthX(i) = abs((indexX(1)-indexX(end)).*0.0977);
    lengthY(i) = abs((indexY(1)-indexY(end)).*0.0977);
    lengthD1(i)= abs((indexD1(1)-indexD1(end)).*0.0977).*sqrt(2);
    lengthD2(i)= abs((indexD2(1)-indexD2(end)).*0.0977).*sqrt(2);
    
    if lengthY(i) > 22
        0;
    end
end

end
