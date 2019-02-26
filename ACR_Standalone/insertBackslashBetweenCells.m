function [ stringOut] = insertBackslashBetweenCells( cellIn )
if iscell(cellIn)
    stringOut = cellIn{1};
    for i = 2:numel(cellIn)
        stringOut = [stringOut '\' cellIn{i}];
    end
elseif isa(cellIn,'char')
    stringOut = cellIn;
else
    error('Unknown type for input into Result struct')
end
    

