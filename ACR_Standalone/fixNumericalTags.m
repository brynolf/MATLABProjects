function str = fixNumericalTags(vector)
str = [];
for i = 1:numel(vector)
    str = [str num2str(vector(i))];
    if i ~= numel(vector)
        str = [str '\'];
    end
end

end