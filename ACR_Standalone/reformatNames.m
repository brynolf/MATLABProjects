function nameString = reformatNames( nameStruct)

nameString = '';
if isstruct(nameStruct)
    fn = fieldnames(nameStruct);
    
    for i = 1:numel(fieldnames(nameStruct));
        nameString = [nameString nameStruct.(fn{i}) '^'];
    end
end

