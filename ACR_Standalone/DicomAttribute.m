classdef DicomAttribute
    % Represent a dicom attribute and its value.
    
    properties (SetAccess = protected, GetAccess = public)
        name;
        group = [];
        element = [];
        VR = '';
        value = [];
        empty = [];
    end
    
    properties (SetAccess = protected, GetAccess = protected)
        
    end
    
    
    methods 
        function obj = DicomAttribute(name,group,element,VR,value,emptyVal)
            % Construct a DicomAttribute object.
            % name  - Name of the attribute. Required.
            % (All these are optional but if one is spec. all must be!)
            % group     - Attribute group
            % element   - Attribute element
            % VR        - Attribute value representation code. E.g.
            %           'LO','CS',...
            % value     - The value of the attribute
            % emptyVal  - If the attribute is empty
            if (nargin >0)
                obj.name = name;
                obj.group = uint16(group);
                obj.element = uint16(element);
                obj.VR = VR;
                obj.value = value;
                obj.empty = emptyVal;
            end 
        end       
        
        function tf = eq(x,y)
            tf = binaryCompare(x,y,@DicomAttribute.internal_eq,'==');
        end
        
        function tf = ne(x,y)
                tf = ~eq(x,y);
        end
        
        function tf = lt(x,y)
            tf = binaryCompare(x,y,@DicomAttribute.internal_lessthan,'<');
        end
        
        function tf = gt(x,y)
            tf = binaryCompare(x,y,@DicomAttribute.internal_greaterthan,'>'); 
        end
        
        function tf = ge(x,y)
            tf = binaryCompare(x,y,@DicomAttribute.internal_greaterthanoreq,'>=');
        end
        
        function tf = le(x,y)
            tf = binaryCompare(x,y,@DicomAttribute.internal_lessthanoreq,'<=');
        end
        
        function tf = not(x) 
            tf = x.empty();
        end
        
        function tf = multiStringMatch(x,str,exact,index)
           % Matches str with x. To be used particularly with x containing 
           % multidimensional strings.
           
           % x must be of correct VR class
           cl = x.getVRClass();
           
           if ~(isequal(cl,'string') || isequal(cl,'uid'))
               error('DicomAtribute:multiStringMatch','Is only defined for strings and uids.');
           end
           
           if (~ischar(str))
              error('The match string must be a string.') 
           end
           
           if (nargin < 3)
               exact = true;
           end
           
           tf = false(size(x.value));
           if (nargin>3)
              useindex = true;
           else
               useindex = false;
               index = 1;
           end
           for ii = 1:numel(x.value)
           	if (iscell(x.value{ii}))
                if (index > numel(x.value{ii}))
                    tf(ii) = false;
                else
                    % Compare strings
                    if (useindex)
                        if (exact)
                            tf(ii) = isequal(x.value{ii}{index},str);
                        else
                            tf(ii) = ~isempty(strfind(x.value{ii}{index},str));
                        end  
                    else
                        N = numel(x.value{ii});
                        for jj = 1:N
                            if (exact)
                                tf(ii) = isequal(x.value{ii}{jj},str);
                            else
                                tf(ii) = ~isempty(strfind(x.value{ii}{jj},str));
                            end
                            if (tf(ii))
                                break;
                            end
                        end
                    end
                end
            else
                if (useindex && index > 1)
                   tf(ii) = false;
                end
                % Compare strings
                if (exact)
                    tf(ii) = isequal(x.value{ii},str);
                else
                    tf(ii) = ~isempty(strfind(x.value{ii},str));
                end
            end
           end 
            
        end
        
        function [obj,index] = sort(obj,order)
            exclude = obj.empty;
            xx = obj.value(~exclude);
            include = DicomAttribute.internalPrepAttribute(xx,getVRClass(obj));
            if (isa(include,'cell'))
                xx(exclude) = {''};
                xx(~exclude) = include;
            else
                xx = zeros(size(xx));
                xx(exclude) = NaN;
                xx(~exclude) = include;
            end
            if (nargin == 1)
               order = 'ascend'; 
            end
            if (isa(include,'cell'))
                [~,index] = sort(xx);
            else
                [~,index] = sort(xx,order);
            end
            obj.empty = obj.empty(index);
            obj.value = obj.value(index);
        end
        
        function obj = subset(obj,index)
            obj.value = obj.value(index);
            obj.empty = obj.empty(index);
        end
        
        function objArray = partition(obj,partitionAttributes)
            % Partition the M attribute(s) obj into M x N attributes.
            
            if (nargin == 1)
                partitionAttributes = obj;
            end

            
            % All objs and partitionAttributes must have the same number of
            % elements
            nElements = numel(obj(1).value);
            for ii = 1:numel(obj)
                if (numel(obj(ii).value) ~= nElements)
                    error('DicomAttribute:partition','All input DicomAttributes must have the same number of values')
                end
            end
            for ii = 1:numel(partitionAttributes)
                if (numel(partitionAttributes(ii).value) ~= nElements)
                    error('DicomAttribute:partition','All input DicomAttributes must have the same number of values')
                end
            end
            
            key = cell(1,numel(obj(1).empty));
            partitionKeys = cell(1,numel(partitionAttributes));
            for ii = 1:numel(partitionAttributes)
                partitionKeys{ii} =  internalpartition(partitionAttributes(ii));
            end
            for jj = 1:numel(key)
                tmp = cell(1,numel(partitionAttributes));
                for ii = 1:numel(partitionAttributes)
                    tmp{ii} =  partitionKeys{ii}{jj};
                end
                key{jj} = [tmp{:}];
            end
            
            [b,~,n] = unique(key);
            N = numel(b);
            objArray = DicomAttribute.empty(numel(obj),0);
            objArray(numel(obj),N) = DicomAttribute();
            
            for mm = 1:numel(obj)
                for nn = 1:N
                    objArray(mm,nn) = obj(mm);
                    objArray(mm,nn).value = obj(mm).value(n==nn);
                    objArray(mm,nn).empty = obj(mm).empty(n==nn);
                end
            end

        end
        
    end
    
    methods (Access = private)
        function strKey = internalpartition(partitionAttribute)
            exclude = partitionAttribute.empty;
            xx = partitionAttribute.value(~exclude);
            include = DicomAttribute.internalPrepAttribute(xx,getVRClass(partitionAttribute));
            if (isa(include,'cell'))
                xx(exclude) = {''};
                xx(~exclude) = include;
            else
                xx = zeros(size(xx));
                xx(exclude) = Inf;
                xx(~exclude) = include;
            end
            
            [~,~,n] = unique(xx);
            % Convert the n to a string
            nTokens = ceil(log(numel(xx))/log(256));
            strKey = cell(1,numel(xx));
            for ii = 1:numel(xx)
                strKey{ii} = DicomAttribute.toCharBase(n(ii),nTokens);
            end
            
        end
        
        function tf = canCompareAttributes(x,y,type)
            % True if the attributes can be compared
            
            % If both are DicomAttributes
            if (isa(x,'DicomAttribute') && isa(y,'DicomAttribute'))
               switch ([getVRClass(x),'-',getVRClass(y)]) 
                   % Numeric types
                   case {'numeric-numeric','age-age','time-time','date-date','datetime-datetime'}
                       tf = true;
                   case 'string-string'
                       tf = true;
                   case {'uid-uid'}
                       if (isequal(type, '=='))
                           tf = true;
                       else
                           tf = false; % For now atleast.
                       end
                   otherwise
                       tf = false;
               end
            else % If one isn't a DicomAttribute
                if (isa(x,'DicomAttribute'))
                    cl1 = getVRClass(x);
                    cl2 = DicomAttribute.getPrimitiveClass(y);
                else
                    cl1 = getVRClass(y);
                    cl2 = DicomAttribute.getPrimitiveClass(x);
                end
                
                switch ([cl1,'-',cl2])
                    case {'numeric-numeric','age-numeric','time-numeric','date-numeric','datetime-numeric'}
                        tf = true;
                    case 'string-string'
                        tf = true;
                    case 'uid-string'
                       if (type == '=')
                           tf = true;
                       else
                           tf = false; % For now atleast.
                       end
                    otherwise
                        tf = false;
                end
            end
        end        
        function cl = getVRClass(x)
           switch (x.VR) 
               case {'FL','FD','SL','SS','DS','IS','UL'}
                   cl = 'numeric';
                   return;
               case {'AE','CS','LO','LT','SH','ST','UT'}
                   cl = 'string';
                   return;
               case {'OB','OF','OW','UN'}
                   cl = 'blob';
               case 'AT'
                   cl = 'tag';
                   return;
               case 'SQ'
                   cl = 'struct';
               case 'AS'
                   cl = 'age';
                   return;
               case {'DA'}
                   cl = 'date';
                   return;
               case 'DT'
                   cl = 'datetime';
                   return;
               case 'TM'
                   cl = 'time';
                   return;
               case 'UI'
                   cl = 'uid';
                   return;
               case 'PN'
                   cl = 'name';
                   return;
               case 'f'
                   cl = 'filename';
               case ''
                   cl = 'empty';
               otherwise
                   error('DicomAttribute:getVRClass','Unknown VR');
           end
        end
        function tf = binaryCompare(x,y,compare_op,type)
            % Check if it is possible to compare x and y
            if (~canCompareAttributes(x,y,type))
               error('DicomAttribute:binaryCompare','Cannot compare.') 
            end
            if (isa(x,'DicomAttribute') && isa(y,'DicomAttribute'))
                tf = false(size(x.empty));
                emptyvals = x.empty | y.empty;
                [a1,a2] = DicomAttribute.prepCompare(x.value(~emptyvals),y.value(~emptyvals),getVRClass(x),true,getVRClass(y),true);
                tf(~emptyvals) = compare_op(a1,a2);
            elseif(isa(x,'DicomAttribute')) % y is a "scalar"
                tf = false(size(x.empty));
                emptyvals = x.empty;
                [a1,a2] = DicomAttribute.prepCompare(x.value(~emptyvals),y,getVRClass(x),true,DicomAttribute.getPrimitiveClass(y),false);
                tf(~emptyvals) = compare_op(a1,a2);
            else % y is dicomattribute
                tf = false(size(x.empty));
                emptyvals = y.empty;
                [a1,a2] = DicomAttribute.prepCompare(x,y.value(~emptyvals),DicomAttribute.getPrimitiveClass(x),false,getVRClass(y),true);
                tf(~emptyvals) = compare_op(a1,a2);
            end
        end
         
    end
    
    methods (Static = true, Access = public)
        function [objArray,files] = read(file,attributes,recursive,progressHandle)
            % Read attributes from dicom files.
            % Inpar:
            % files         - Files can be a path or a cell array of filenames.
            % attributes    - Attributes are a list of attribute names in agreement with
            %               the names found in dicom-dict.txt. Cell array 1
            %               x n. A attribute can also be a pair of two
            %               number [group,element]. In this case the name
            %               of the tag will be private_(group)_(element).
            % recursive     - Recursively search the path. Only used if
            %               files is a path. Optional default = false.
            %
            %
            % Outpar:
            % A m x n+1 array of DicomAttributes. m is the number of found
            % dicom files. n is the number of attributes and the + 1 is due
            % to that output(:,1) contains filenames.
            
            if (isa(file,'cell'))
                usefiles = true;
            else
                usefiles = false;
            end
            
            if (nargin < 3)
               recursive = false; 
            end
            
            if (nargin < 4)
                viewProgress = false;
            else
                viewProgress = true;
            end
            
            % Get the attribute group, element and name.
            internalAttributeCodes = zeros(2,numel(attributes),'uint16');
            internalAttributeNames = cell(size(attributes));
            
            for ii = 1:numel(attributes)
                at = strtrim(attributes{ii}); % Remove leading and trailing whitespaces.
                if (isa(at,'char'))
                    [g,e] = dicomlookup(at);
                    if (isempty(g))
                        % Check if private
                        if (~isempty(strfind(at,'Private_')))
                            tmp = regexpi(at,'private_([0-9a-f]+)_([0-9a-f]+)','tokens','once');
                            if (~isempty(tmp))
                                g = uint16(hex2dec(tmp{1}));
                                e = uint16(hex2dec(tmp{2}));
                            else
                                error('DicomAttribute:read',['Unknow attribute: ',at]);
                            end
                        else
                            error('DicomAttribute:read',['Unknow attribute: ',at]);
                        end
                    end
                    internalAttributeCodes(1,ii) = uint16(g);
                    internalAttributeCodes(2,ii) = uint16(e);
                    internalAttributeNames{ii} = at;
                elseif (isnumeric(at))
                    if (numel(at) == 2)
                        g = uint16(at(1));
                        e = uint16(at(2));
                        aname = dicomlookup(g,e);
                        if (isempty(aname))
                            aname = ['Private_',dec2hex(g),'_',dec2hex(e)];
                        end
                        internalAttributeCodes(1,ii) = g;
                        internalAttributeCodes(2,ii) = e;
                        internalAttributeNames{ii} = aname;
                    else
                        error('DicomAttribute:read','Bad attribute!');
                    end
                else
                    error('DicomAttribute:read','Bad attribute. Must be name or [group,element]');
                end
            end
            % Get all the attributes
            if (viewProgress)
                [files,data] = gdcmDicomInfo(file,usefiles,logical(recursive),internalAttributeCodes(1,:),internalAttributeCodes(2,:),func2str(progressHandle));
            else
                [files,data] = gdcmDicomInfo(file,usefiles,logical(recursive),internalAttributeCodes(1,:),internalAttributeCodes(2,:));
            end
           
            
            
            % Remove data that wasn't dicoms
            filesTrim = false(size(files{1}));
            dataTrim = false(size(data{1}));

            for ii = 1:size(filesTrim,1)
               if (~files{3}(ii)) 
                   filesTrim(ii,:) = true;
                   dataTrim(ii,:) = true;
               end
            end
            nFiles = sum(filesTrim);
            for ii = 1:numel(data)
                data{ii} = reshape(data{ii}(dataTrim),[nFiles,size(dataTrim,2)]);
                files{ii} = files{ii}(filesTrim);
            end
            if (isempty(data))
                objArray = [];
                files = [];
                return;
            end

            
            
            
            % Create output
            objArray = DicomAttribute.empty(1,0);
            
            % Interpret the result in data and fill in accordingly into the
            % attributes.
            
            % The file information
            files = DicomAttribute('FileName',NaN,NaN,'f',files{2},files{3});
            
            % The attributes
            if (size(data{1},2)==0)
                return;
            end
            
            objArray(1,size(data{1},2)) = DicomAttribute();
            for iAttributes = 1:(size(data{1},2))
                c = internalAttributeCodes(:,iAttributes);
                n = internalAttributeNames{iAttributes};
                % Check that VR is OK
                vr = data{1}(:,iAttributes);
                emptyVals = data{3}(:,iAttributes);
                vr = unique(vr(~emptyVals));
                if (isempty(vr))
                    vr = {''};
                end
                if ((numel(vr)~= 1) && ~isempty(vr))
                    error('DicomAttribute:Read','Found an attribute with different VR in differnt files!')
                end
                
                % Special treatment is needed for VR = SQ. Some of a ugly
                % fix to handle sequences. Part of the reading of sequences
                % is in the mex file while the interpretation is here. Not
                % the best coding since it is not really homogeneous with
                % how other attributes are treated. But seems to work for
                % now.
                if (isequal(vr{1},'SQ'))
                    data2 = cell(size(data{2}(:,iAttributes)));
                    for iO = 1:numel(data{2}(:,iAttributes))
                        data2{iO} = DicomAttribute.processIfSequence(vr{1},data{2}{iO,iAttributes});
                    end
                else
                    data2 =  data{2}(:,iAttributes);
                end
                
                
                objArray(1,iAttributes) = DicomAttribute(n,c(1),c(2),vr{1},data2,emptyVals); 
            end   
        end
        
        function updateProgress(progressHandle,value)
           h = str2func(progressHandle);
           h(value); 
        end
    end
    
    methods (Static = true, Access = private)
        
        function data2 = processIfSequence(vr,data)
            if (isequal(vr,'SQ'))
                data2 = cell(size(data));
                % Loop over data objects
                    for iI = 1:numel(data)
                        % Create a struct representing the item
                        item = struct;
                        % Loop over elements in item
                        for iE = 1:numel(data{iI})
                            % Get name of element in the item
                            g = data{iI}(iE).Group;
                            e = data{iI}(iE).Element;
                            ename = dicomlookup(g,e);
                            if (isempty(ename))
                                ename = ['Private_',dec2hex(g),'_',dec2hex(e)];
                            end
                            item.(ename) = DicomAttribute.processIfSequence(data{iI}(iE).VR,data{iI}(iE).value);
                        end
                        data2{iI} = item;
                    end
            else
                data2 = data;
            end
            
        end
        
        function str = toCharBase(n,nTokens)
           str = zeros(1,nTokens,'uint8');
           for ii = nTokens:(-1):1
               str(ii) = mod(n,256);
               n = floor(n/256);
           end
           str = char(str);
        end
        
        function c = getPrimitiveClass(x)
           if (ischar(x))
               c = 'string';
           elseif (isnumeric(x))
               c = 'numeric';
           else
               c = class(x);
           end
        end
        
        function xxval = internalPrepPrimitive(xx,nx,cl)
            switch (cl)
                case {'numeric','age'}
                    if (~isnumeric(xx))
                        error('DicomAttribute:prepCompare','Can only compare numeric values wit numeric values');
                    end
                    if (numel(xx) ~= 1)
                        error('DicomAttribute:prepCompare','Can only compare scalars');
                    end
                    xxval = xx*ones(1,nx);
                case {'string','uid'}
                    xxval = cell(1,nx);
                    
                    if (~isa(xx,'char'))
                        error('DicomAttribute:prepCompare','Wrong type in comparison with string/uid.');
                    end
                    
                    for ii = 1:nx
                        xxval{ii} = xx;
                    end
                    
                case {'time','date','datetime'}
                    if(isnumeric(xx)&&isscalar(xx))
                        xxval = xx*ones(1,nx);
                    end
                otherwise
                    error('DicomAttribute:prepCompare','The VR cannot be compared.');
            end
        end
        
        function xxval = internalPrepAttribute(xx,cl)
            switch (cl)
                case {'numeric','age'}
                    xxval = zeros(1,numel(xx));
                    for ii = 1:numel(xx)
                        tmp = xx{ii};
                        if (numel(tmp)==1)
                            xxval(ii) = tmp;
                        else
                            error('DicomAttribute:prepCompare','Cannot compare non-scalar numbers.');
                        end
                    end
                case {'string','uid','filename'}
                    xxval = xx;
                    for ii = 1:numel(xx)
                        if (~isa(xx{ii},'char'))
                            % Make a single string out of the parts
                            xxval{ii} = '';
                            for jj = 1:numel(xx{ii})
                               xxval{ii} = [xxval{ii},'\',xx{ii}{jj}];
                            end
                            xxval{ii} = xxval{ii}(2:end);
                        end
                    end
                case 'time'
                    for ii = 1:numel(xx)
                        if (isa(xx{ii},'char'))
                            xx{ii} = xx{ii}(xx{ii} ~= ':');
                        else
                            error('DicomAttribute:prepCompare','Cannot compare multidimensional times.');
                        end
                    end
                    xxval = datenum(xx,'HHMMSS.FFF');
                    
                case 'date'
                    for ii = 1:numel(xx)
                        if (isa(xx{ii},'char'))
                            xx{ii} = xx{ii}(xx{ii} ~= '.');
                        else
                            error('DicomAttribute:prepCompare','Cannot compare multidimensional dates.');
                        end
                    end
                    xxval = datenum(xx,'yyyymmdd');
                case 'datetime'
                    for ii = 1:numel(xx)
                        if (isa(xx{ii},'char'))
                            offset = (xx{ii} == '&');
                            if (any(offset))
                                xx{ii} = xx{ii}(1:(find(offset)-1));
                            end
                        else
                            error('DicomAttribute:prepCompare','Cannot compare multidimensional datetimes.');
                        end
                    end
                    xxval = datenum(xx,'yyyymmddHHMMSS.FFF');
                case 'empty'
                    xxval = xx;
                otherwise
                    error('DicomAttribute:prepCompare','The VR cannot be compared/sorted.');
            end
        end
        
        function [xval,yval] = prepCompare(x,y,cl1,isattr1,cl2,isattr2)
            % Prepare attributes and primitives that are to be compared.
            % Also check for some errors. After prep xval and yval are
            % either scalars or strings. And can thereafter easily be
            % compared.

            % If x is a DicomAttribute
            if (isattr1)
                xval = DicomAttribute.internalPrepAttribute(x,cl1);
            else % y is an Attrbute and x must be transformed to appropriate type. 
                % And the size of x must become the same as y.
                xval = DicomAttribute.internalPrepPrimitive(x,numel(y),cl2);
                
            end
            
            % If y is a DicomAttribute
            if (isattr2)
                yval = DicomAttribute.internalPrepAttribute(y,cl2);
            else
                yval = DicomAttribute.internalPrepPrimitive(y,numel(x),cl1);
            end
            
                
            
        end
        
        function tf = internal_eq(xval,yval)
            if (isa(xval(1),'cell'))
                tf = false(size(xval));
                for ii = 1:numel(xval)
                    tf(ii) = isequal(xval{ii},yval{ii});
                end
            else
                tf = xval==yval;
            end
        end
        
        function tf = internal_lessthan(xval,yval)
            if (isa(xval(1),'cell'))
                tf = false(size(xval));
                if (isa(xval{1},'char'))
                    for ii = 1:numel(xval)
                        in = ~isempty(strfind(yval{ii},xval{ii}));
                        tf(ii) = ~isequal(xval{ii},yval{ii}) && in;
                    end
                else
                    error('DicomAttribute:internal_lessthan','Strings are currently the only complex types allowed.')
                end
            else
                tf = xval<yval;
            end
        end
        
        function tf = internal_lessthanoreq(xval,yval)
            if (isa(xval(1),'cell'))
                tf = false(size(xval));
                if (isa(xval{1},'char'))
                    for ii = 1:numel(xval)
                        in = ~isempty(strfind(yval{ii},xval{ii}));
                        tf(ii) = in;
                    end
                else
                    error('DicomAttribute:internal_lessthan','Strings are currently the only complex types allowed.')
                end
            else
                tf = xval<=yval;
            end
        end
        
        function tf = internal_greaterthan(xval,yval)
            if (isa(xval(1),'cell'))
                tf = false(size(xval));
                if (isa(xval{1},'char'))
                    for ii = 1:numel(xval)
                        in = ~isempty(strfind(xval{ii},yval{ii}));
                        tf(ii) = ~isequal(xval{ii},yval{ii}) && in;
                    end
                else
                    error('DicomAttribute:internal_lessthan','Strings are currently the only complex types allowed.')
                end
            else
                tf = xval>yval;
            end
        end
        
        function tf = internal_greaterthanoreq(xval,yval)
            if (isa(xval(1),'cell'))
                tf = false(size(xval));
                if (isa(xval{1},'char'))
                    for ii = 1:numel(xval)
                        in = ~isempty(strfind(xval{ii},yval{ii}));
                        tf(ii) = in;
                    end
                else
                    error('DicomAttribute:internal_lessthan','Strings are currently the only complex types allowed.')
                end
            else
                tf = xval>=yval;
            end
        end
    end
end


