classdef  LoopCounter
    properties (SetAccess = private,GetAccess = private)
        dimArray
        loopIndexes
    end
    
    properties (GetAccess = public, SetAccess = private)
        running;
        nDims;
        dimSize;
        linearIndex;
    end
    
    properties (SetAccess = private, GetAccess = public, Dependent = true)
        size
        index
        value
    end
    
    methods 
        function v = get.size(lc)
            v = lc.dimSize;
        end
        function ii = get.index(lc)
            ii = num2cell(lc.loopIndexes);
        end
        function val = get.value(lc)
            % Get current value of counter
            val = cell(1,lc.nDims);
            for ii = 1:lc.nDims
                element = lc.dimArray{ii}(lc.loopIndexes(ii));
                if (iscell(element))
                    val{ii} = element{1};
                else
                    val{ii} = element;
                end
            end
        end
    end
    
    methods
        function lc = LoopCounter(dimArray)
            % Create a loopcounter object used for looping over ND objects
            %
            % Inpar:
            % <dimArray>  - A cell array of values in each dimension.
            %               E.g. {[1 2 3 4 5],{'Hund','Katt'},'abcdef'}
            %
            %
            lc.dimArray = dimArray;
            lc.linearIndex = 1;
            lc.running  = true;
            lc.nDims    = numel(dimArray);
            lc.dimSize  = zeros(1,lc.nDims);
            for ii = 1:lc.nDims
                lc.dimSize(ii) = numel(dimArray{ii});
            end
            lc.loopIndexes = ones(1,lc.nDims);
        end
        
        function lc = increment(lc)
            % Increment the loopcounter
            if (lc.running)
                lc.linearIndex = lc.linearIndex + 1;
                for ii = 1:lc.nDims
                    if (lc.loopIndexes(ii) < lc.dimSize(ii))
                        lc.loopIndexes(ii) = lc.loopIndexes(ii) + 1;
                        break;
                    else
                        lc.loopIndexes(ii) = 1;
                        if (ii == lc.nDims)
                            lc.running = false; % Reached the end of the loop
                        end
                    end
                end
            end
        end
                
        function lc = reset(lc)
            % Reset the loop counter
            lc.running = true;
            lc.loopIndexes = ones(1,lc.nDims);
            lc.linearIndex = 1;
        end        
        
    end
end
